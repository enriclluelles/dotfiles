---
name: prod-mysql-query
description: Run MySQL queries against a Factorial MySQL database (AWS production, AKS production, or AKS demo) using a throwaway pod in the matching Kubernetes cluster. Use when you need to query production or demo data, inspect tables, check records, or run read-only SQL.
---

# Factorial MySQL Query

Run MySQL commands against a Factorial database by spinning up a pod in the
matching Kubernetes cluster. The pod stays alive for the TTL duration, so you
can run multiple queries against it without waiting for a new pod each time.

Three environments are supported. **`aws-production` is the default** — use it
unless the user names another environment.

| Environment | `CTX` | Secret | Database | Read host |
|-------------|-------|--------|----------|-----------|
| `aws-production` (default) | `aws-production-blue` | `dbcredentials` | RDS `factorialmysql8` (MySQL 8.0) | replica (`$DB_READ_REPLICA_HOST`) |
| `aks-production` | `azure-prod-eu2-blue` | `factorial-backend-secret` | Azure MySQL Flexible Server `mysql-app-prod-gwc-eu2` (8.0.45-azure) | **master (`$DB_HOST`)** |
| `aks-demo` | `azure-demo-eu2-blue` | `factorial-backend-secret` | Azure MySQL Flexible Server `mysql-app-demo-gwc-eu2` (8.0.45-azure) | **master (`$DB_HOST`)** |

All three use namespace `factorial-backend` and pod name `mysql-enric-lluelles`.
The pod name is the same in every cluster — the `--context` is what selects the
environment, so **never omit `--context`**.

**The two cloud providers store credentials under completely different secret
keys.** That is why pod creation differs per environment; everything after
pod creation is identical.

## Running Queries

Set `CTX` once, then reuse it. Try to exec into the pod first — only create it
if it doesn't exist or isn't running.

```bash
CTX=aws-production-blue   # or azure-prod-eu2-blue / azure-demo-eu2-blue
```

**Important:** The env vars (`$DB_READ_REPLICA_HOST`, `$DB_USER`, etc.) exist
inside the pod, not locally. You **must** wrap the command with `bash -c '...'`
(single quotes) so the pod's shell expands them.

### Reads

**`aws-production` — use the replica:**

```bash
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "<YOUR_SQL_QUERY>"'
```

**`aks-production` / `aks-demo` — use the master (`$DB_HOST`):**

```bash
kubectl --context $CTX -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "<YOUR_SQL_QUERY>"'
```

The Azure environments deliberately query the master for reads as well as
writes, so the replica endpoints are **not wired into the pod** — there is no
`$DB_READ_REPLICA_HOST` there. This avoids replica lag entirely and means a
read-back always reflects a write you just made.

If a host variable is ever empty, an empty `-h` makes the mysql client
silently fall back to a local socket and fail with:

```
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
```

That error means the variable was blank — echo it before debugging further.

### Writes — master host, explicit confirmation only

```bash
kubectl --context $CTX -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "<YOUR_SQL_QUERY>"'
```

**Replace `<YOUR_SQL_QUERY>` with the actual SQL.** Use single quotes for the
outer `bash -c` wrapper to prevent local shell expansion.

On `aws-production`, verify a write by reading back **from the master**
(`$DB_HOST`), not the replica — replica lag can make a successful write look
like it did not apply. On the Azure environments every query already goes to
the master, so a read-back is automatically consistent.

### Confirming which host you reached

`@@read_only` is the reliable check: `1` on a replica, `0` on a master. On the
Azure environments it should always report `0`.

```bash
kubectl --context $CTX -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT @@hostname, @@read_only, VERSION();"'
```

## Creating the Pod

If exec fails because the pod doesn't exist, is in `DeadlineExceeded`/`Failed`
status, or is not running, create it with the block for that environment.

Both providers connect over plain TCP on port 3306 — no TLS flags or CA bundle
are needed, including for Azure MySQL Flexible Server.

### `aws-production` (secret `dbcredentials`, lowercase keys)

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
          {"name": "DB_PORT", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "port"}}},
          {"name": "DB_READ_REPLICA_HOST", "valueFrom": {"secretKeyRef": {"name": "dbcredentials", "key": "read_replica_host"}}}
        ]
      }]
    }
  }'
kubectl --context aws-production-blue -n factorial-backend wait --for=condition=Ready pod/mysql-enric-lluelles --timeout=90s
```

### `aks-production` / `aks-demo` (secret `factorial-backend-secret`, `DATABASE_*` keys)

Identical apart from the context. Set `CTX` to `azure-prod-eu2-blue` or
`azure-demo-eu2-blue` first. No replica host is wired in — these environments
query the master only.

```bash
CTX=azure-prod-eu2-blue   # or azure-demo-eu2-blue
kubectl --context $CTX -n factorial-backend delete pod mysql-enric-lluelles --ignore-not-found
kubectl --context $CTX -n factorial-backend run mysql-enric-lluelles \
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
          {"name": "DB_HOST", "valueFrom": {"secretKeyRef": {"name": "factorial-backend-secret", "key": "DATABASE_HOST"}}},
          {"name": "DB_USER", "valueFrom": {"secretKeyRef": {"name": "factorial-backend-secret", "key": "DATABASE_USERNAME"}}},
          {"name": "DB_PASS", "valueFrom": {"secretKeyRef": {"name": "factorial-backend-secret", "key": "DATABASE_PASSWORD"}}},
          {"name": "DB_NAME", "valueFrom": {"secretKeyRef": {"name": "factorial-backend-secret", "key": "DATABASE_NAME"}}},
          {"name": "DB_PORT", "valueFrom": {"secretKeyRef": {"name": "factorial-backend-secret", "key": "DATABASE_PORT"}}}
        ]
      }]
    }
  }'
kubectl --context $CTX -n factorial-backend wait --for=condition=Ready pod/mysql-enric-lluelles --timeout=90s
```

Then retry the exec command.

## Auth Recovery

### `aws-production` (AWS SSO)

1. **Token expired / unauthorized** (`error: You must be logged in`,
   `token has expired`, `Unauthorized`, or
   `Error when retrieving token from sso: Token has expired and refresh failed`):
   ```bash
   aws sso login --profile production
   ```

2. **Context not found** (`context "aws-production-blue" does not exist`):
   ```bash
   aws sso login --profile production
   aws eks update-kubeconfig --name aws-prod-eucentral1-glob01-blue --region eu-central-1 --profile production --alias aws-production-blue
   ```

### `aks-production` / `aks-demo` (Azure AD via kubelogin)

These contexts authenticate with `kubelogin get-token --login azurecli`, so they
depend on a valid `az` session — **not** on AWS SSO.

1. **Token expired / unauthorized:**
   ```bash
   az login
   ```

2. **Context not found:**
   ```bash
   az login
   # aks-production
   az aks get-credentials --resource-group prod-gwc-eu2 --name aks-prod-gwc-eu2-blue --context azure-prod-eu2-blue
   # aks-demo
   az aks get-credentials --resource-group demo-gwc-eu2 --name aks-demo-gwc-eu2-blue --context azure-demo-eu2-blue
   ```

Then retry. **Note:** `aws sso login` and `az login` both open a browser window.
Wait for the user to complete the flow.

### Cleanup

The pod auto-terminates after the TTL expires. To manually delete it early:

```bash
kubectl --context $CTX -n factorial-backend delete pod mysql-enric-lluelles
```

Pods in different clusters are independent — deleting one leaves the others
running, and each must be cleaned up with its own `--context`.

## Pod TTL (activeDeadlineSeconds)

The default TTL is **30 minutes** (`activeDeadlineSeconds: 1800`). Kubernetes
kills the pod after this duration.

| Duration | Value |
|----------|-------|
| 30 minutes (default) | `1800` |
| 1 hour | `3600` |
| 2 hours | `7200` |
| 4 hours | `14400` |

If the user asks for more time, delete the pod and recreate it with a higher
`activeDeadlineSeconds`.

## Safety Rules

- **`aws-production`: prefer the read replica** (`DB_READ_REPLICA_HOST`) for
  SELECT queries
- **`aks-production` / `aks-demo`: always use the master** (`DB_HOST`) — the
  replicas are intentionally not wired in. Bear in mind this puts ad-hoc read
  load on the master, so keep queries indexed and `LIMIT`ed
- **NEVER run** `DROP`, `TRUNCATE`, `DELETE`, or `UPDATE` statements without
  explicit user confirmation
- **NEVER run** DDL statements (`ALTER TABLE`, `CREATE`, etc.) — those must go
  through migrations
- **Confirm the environment before any write.** `aws-production` and
  `aks-production` are both live customer data in different clouds; they are
  not copies of each other. State which environment you are about to write to
  and get confirmation for that specific one.
- **Scope writes by primary key** and report `ROW_COUNT()` rather than assuming
  success. A `0` row count means the target row did not exist — stop and
  re-check rather than inserting one
- **Wrap queries with a timeout** for safety: prefix SQL with
  `SET SESSION max_execution_time=30000;` (30s) for ad-hoc queries
- If a query might return a large result set, add `LIMIT` to avoid overwhelming
  output

## Examples

```bash
# Count records (aws-production, via replica)
kubectl --context aws-production-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_READ_REPLICA_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM employees;"'

# Same count on aks-production (master)
kubectl --context azure-prod-eu2-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM employees;"'

# aks-demo (master)
kubectl --context azure-demo-eu2-blue -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM employees;"'

# Show tables (Azure — master)
kubectl --context $CTX -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES LIKE '\''%employee%'\'';"'

# Describe a table (Azure — master)
kubectl --context $CTX -n factorial-backend exec mysql-enric-lluelles -- bash -c 'mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE employees;"'
```

## Available Secret Keys

### `aws-production` — `dbcredentials` (namespace `factorial-backend`)

| Key | Description | Env var in pod |
|-----|-------------|----------------|
| `host` | Primary RDS writer endpoint | `DB_HOST` |
| `read_replica_host` | Read replica endpoint (prefer for SELECTs) | `DB_READ_REPLICA_HOST` |
| `read_replica_host2` | Second read replica endpoint | — |
| `username` | Database username | `DB_USER` |
| `password` | Database password | `DB_PASS` |
| `dbname` | Database name | `DB_NAME` |
| `port` | Database port (3306) | `DB_PORT` |
| `engine` | Database engine (mysql) | — |
| `masterarn` | Secrets Manager ARN of the master secret | — |

### `aks-production` / `aks-demo` — `factorial-backend-secret` (namespace `factorial-backend`)

This is the backend's large application secret; the keys below are the
database-related subset.

| Key | Description | Env var in pod |
|-----|-------------|----------------|
| `DATABASE_HOST` | Master Flexible Server endpoint — **used for all queries** | `DB_HOST` |
| `REPLICA_DATABASE_HOST` | Read replica endpoint — not wired in (and empty on `aks-demo`) | — |
| `SECONDARY_REPLICA_DATABASE_HOST` | Reports replica (`aks-production` only) — not wired in | — |
| `DATABASE_USERNAME` | Database username (`adminFactorial`) | `DB_USER` |
| `DATABASE_PASSWORD` | Database password | `DB_PASS` |
| `DATABASE_NAME` | Database name (`factorial`) | `DB_NAME` |
| `DATABASE_PORT` | Database port (3306) | `DB_PORT` |
| `REPLICA_DATABASE_PORT` | Replica port (`aks-production` only) | — |

## Infrastructure Context

### `aws-production`

- **AWS Profile:** `production` (account `771567148620`)
- **K8s Context:** `aws-production-blue`
- **EKS Cluster:** `aws-prod-eucentral1-glob01-blue` in `eu-central-1`
- **Namespace:** `factorial-backend`
- **Secret:** `dbcredentials` (synced via ExternalSecret
  `backend-database-creds` from AWS Secrets Manager
  `production/database_credentials`)
- **RDS Instance:** `factorialmysql8` (MySQL 8.0, `db.m6i.16xlarge`)
- **Read Replica Class:** `db.m6g.4xlarge`

### `aks-production`

- **K8s Context:** `azure-prod-eu2-blue`
- **AKS Cluster:** `aks-prod-gwc-eu2-blue`, resource group `prod-gwc-eu2`
  (Germany West Central)
- **Auth:** `kubelogin get-token --login azurecli` (requires `az login`)
- **Namespace:** `factorial-backend`
- **Secret:** `factorial-backend-secret`
- **Server:** `mysql-app-prod-gwc-eu2.mysql.database.azure.com`
  (Azure MySQL Flexible Server, 8.0.45-azure)
- **Replicas:** `-replica-backend` (general) and `-replica-reports` (reports)

### `aks-demo`

- **K8s Context:** `azure-demo-eu2-blue`
- **AKS Cluster:** `aks-demo-gwc-eu2-blue`, resource group `demo-gwc-eu2`
- **Auth:** `kubelogin get-token --login azurecli` (requires `az login`)
- **Namespace:** `factorial-backend`
- **Secret:** `factorial-backend-secret`
- **Server:** `mysql-app-demo-gwc-eu2.mysql.database.azure.com`
  (Azure MySQL Flexible Server, 8.0.45-azure)
- **Replicas:** none — `REPLICA_DATABASE_HOST` is empty
