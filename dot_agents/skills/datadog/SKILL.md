---
name: datadog
description: Use when the user asks for information from Datadog — logs, metrics, monitors, APM, traces, dashboards, incidents, etc. Always use the `pup` CLI tool unless the user explicitly asks to use the web UI or API directly.
---

# Datadog via pup CLI

Always use the `pup` command-line tool to query Datadog. Do **not** open the Datadog web UI or call the API directly unless the user explicitly asks for it.

## General Usage

```bash
pup <command> [subcommand] [options]
```

Output formats: `--output json` (default), `--output table`, `--output yaml`

## Common Commands

### Logs
```bash
# Search logs
pup logs search --query="service:my-service status:error" --from="1h"

# Search in specific storage tier
pup logs search --query="service:my-service" --from="7d" --storage-tier=flex
```

### Metrics
```bash
# Query metrics
pup metrics query --query="avg:system.cpu.user{env:production}" --from="1h" --to="now"

# List available metrics
pup metrics list --filter="app.*"
```

### Monitors
```bash
# List monitors
pup monitors list --name="keyword"
pup monitors list --tags="env:production,team:backend"

# Get monitor details
pup monitors get <monitor_id>
```

### APM & Traces
```bash
# List services with performance stats
pup apm services stats --start $(date -v-1H +%s) --end $(date +%s)

# View service dependencies
pup apm dependencies <service_name>

# Search spans
pup traces search --query="service:web-server @http.status_code:500"

# Aggregate traces
pup traces aggregate --query="service:api" --compute="percentile(@duration, 99)" --group-by="resource_name"
```

### Dashboards
```bash
# List dashboards
pup dashboards list

# Get dashboard details
pup dashboards get <dashboard_id>
```

### Incidents
```bash
pup incidents list
```

### Infrastructure
```bash
pup infrastructure --help
```

## Time Ranges

- Relative short: `1h`, `30m`, `7d`, `5s`, `1w`
- Relative long: `5min`, `2hours`, `3days`
- Absolute: Unix timestamps in milliseconds

## Discovering Commands

When unsure about a subcommand:
```bash
pup <command> --help
```

## Rules

- **Always** use `pup` for Datadog queries unless the user explicitly says otherwise.
- Prefer `--output table` when showing results to the user for readability.
- Use `--output json` when piping to `jq` or processing programmatically.
- Check `pup <command> --help` when unsure about available options.
