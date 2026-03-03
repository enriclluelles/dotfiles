---
name: prod-mysql-query
description: Run MySQL queries against the Factorial production database using a throwaway pod in the production EKS cluster. Use when you need to query production data, inspect tables, check records, or run read-only SQL against the production MySQL database.
---

# Production MySQL Query

Run MySQL commands against the Factorial production RDS database by spinning up a pod in the production Kubernetes cluster (`aws-production-blue`). The pod stays alive for the TTL duration, so you can run multiple queries against it without waiting for a new pod each time.

## Prerequisites

- AWS CLI with SSO configured (`production` profile)
- `kubectl` installed

## Running Queries

The pod name is always `mysql-enric-lluelles`. Try to exec into it first — only create it if it doesn't exist or isn't running.

### Try to run the query directly

**Important:** The env vars (`$DB_READ_REPLICA_HOST`, `$DB_USER`, etc.) exist inside the pod, not locally. You **must** wrap the command with `bash -c '...'` (single quotes) so the pod's shell expands them.

```bash
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "<YOUR_SQL_QUERY>"'
```

For writes (use primary host — only with explicit user confirmation):

```bash
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "<YOUR_SQL_QUERY>"'
```

**Replace `<YOUR_SQL_QUERY>` with the actual SQL.** Use single quotes for the outer `bash -c` wrapper to prevent local shell expansion.

### If exec fails: create or recreate the pod

If the exec fails because the pod doesn't exist, is in `DeadlineExceeded`/`Failed` status, or is not running:

```bash
kubectl --context aws-production-blue -n factorial-backend delete pod mysql-enric-lluelles --ignore-not-found
kubectl --context aws-production-blue -n factorial-backend run mysql-enric-lluelles \
  --restart=Never \
  --image=mysql:8.0 \
  --overrides='{
    "spec": {
      "activeDeadlineSeconds": 1800,
      "containers": [{
        "name": "mysql",
        "image": "mysql:8.0",
        "command": ["sleep", "infinity"],
        "env": [
          {"name": "DB_HOST", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "host"}}},
          {"name": "DB_USER", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "username"}}},
          {"name": "DB_PASS", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "password"}}},
          {"name": "DB_NAME", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "dbname"}}},
          {"name": "DB_READ_REPLICA_HOST", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "read_replica_host"}}}
        ]
      }]
    }
  }'
kubectl --context aws-production-blue -n factorial-backend wait --for=condition=Ready pod/mysql-enric-lluelles --timeout=60s
```

Then retry the exec command.

### If kubectl itself fails: auth recovery

If the kubectl command fails with auth/context errors:

1. **Token expired / unauthorized** (`error: You must be logged in`, `token has expired`, `Unauthorized`):
   ```bash
   aws sso login --profile production
   ```

2. **Context not found** (`context "aws-production-blue" does not exist`):
   ```bash
   aws sso login --profile production
   aws eks update-kubeconfig --name aws-prod-eucentral1-glob01-blue --region eu-central-1 --profile production --alias aws-production-blue
   ```

Then retry. **Note:** `aws sso login` may open a browser window. Wait for the user to complete the flow.

### Cleanup

The pod auto-terminates after the TTL expires. To manually delete it early:

```bash
kubectl --context aws-production-blue -n factorial-backend delete pod mysql-enric-lluelles
```

## Pod TTL (activeDeadlineSeconds)

The default TTL is **30 minutes** (`activeDeadlineSeconds: 1800`). Kubernetes kills the pod after this duration.

| Duration | Value |
|----------|-------|
| 30 minutes (default) | `1800` |
| 1 hour | `3600` |
| 2 hours | `7200` |
| 4 hours | `14400` |

If the user asks for more time, delete the pod and recreate it with a higher `activeDeadlineSeconds`.

## Safety Rules

- **ALWAYS prefer the read replica** (`DB_READ_REPLICA_HOST`) for SELECT queries
- **NEVER run** `DROP`, `TRUNCATE`, `DELETE`, or `UPDATE` statements without explicit user confirmation
- **NEVER run** DDL statements (`ALTER TABLE`, `CREATE`, etc.) — those must go through migrations
- **Wrap queries with a timeout** for safety: prefix SQL with `SET SESSION max_execution_time=30000;` (30s) for ad-hoc queries
- If a query might return a large result set, add `LIMIT` to avoid overwhelming output

## Examples

```bash
# Count records
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM employees;"'

# Show tables
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES LIKE '\''%employee%'\'';"'

# Describe a table
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE employees;"'
```

## Available Secret Keys

The `dbcredentials` secret in `factorial-backend` namespace contains:

| Key | Description | Env var in pod |
|-----|-------------|----------------|
| `host` | Primary RDS writer endpoint | `DB_HOST` |
| `read_replica_host` | Read replica endpoint (prefer for SELECTs) | `DB_READ_REPLICA_HOST` |
| `read_replica_host2` | Second read replica endpoint | — |
| `username` | Database username | `DB_USER` |
| `password` | Database password | `DB_PASS` |
| `dbname` | Database name | `DB_NAME` |
| `port` | Database port (3306) | — |
| `engine` | Database engine (mysql) | — |

## Infrastructure Context

- **AWS Profile:** `production` (account `771567148620`)
- **K8s Context:** `aws-production-blue`
- **EKS Cluster:** `aws-prod-eucentral1-glob01-blue` in `eu-central-1`
- **K8s Version:** v1.32
- **Namespace:** `factorial-backend`
- **Secret:** `dbcredentials` (synced via ExternalSecret `backend-database-creds` from AWS Secrets Manager `production/database_credentials`)
- **RDS Instance:** `factorialmysql8` (MySQL 8.0, `db.m6i.16xlarge`)
- **Read Replica Class:** `db.m6g.4xlarge`
