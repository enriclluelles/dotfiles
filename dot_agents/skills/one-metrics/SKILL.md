---
name: one-metrics
description: Read One metrics, the AI Lab's dashboard of One's sessions, from the terminal with the one-metrics CLI - sign-in through the browser, dashboard figures, breakdowns, waiting times, sessions and their transcripts, with the dashboard's filters; report counts and outcomes, never user content or names
---

# One metrics from the CLI

`one-metrics` is the platform's command-line client (`architecture/cli.md`). `one-metrics help --json` is its whole contract, commands, flags, filters, formats and exit statuses: run it once and work from it.

## Setup

- Build: `make cli` from the repository root puts it at `backend/bin/one-metrics`; or `GOPRIVATE=github.com/factorialco go install github.com/factorialco/one-metrics/backend/cmd/one-metrics@latest`.
- Sign in: `one-metrics login` opens the browser at the dashboard's CLI sign-in page, where a **person must click Approve**. Tell the user that before running it, run it, and wait: it returns once they approved, or after five minutes. The CLI then carries the browser's session, which ends when the browser's does, 12 hours after the person signed in; `whoami` shows `sessionExpiresAt`.
- Exit status 3 means not signed in or expired: run `one-metrics login` again and ask the person to approve. Status 2 is a usage error, answered with the command's help; 1 is the API's or the network's error, with its message on standard error.
- The local cluster, `--url https://metrics.k8s.orb.local`, needs no sign-in.
- The CLI compares its build with the platform's once a day and replaces itself, and this skill, when they differ; `one-metrics update` does it now, `one-metrics version` shows both builds.

## Reading data

| Command | Gives |
|---------|-------|
| `summary [filters]` | Sessions, satisfaction counts, intent coverage, companies, users, tokens, cost, credits |
| `timeseries --by day [filters]` | Sessions and satisfaction counts per hour, day or week |
| `breakdown --by intent [filters]` | Per-slice sessions, share, satisfaction, tokens, cost, credits; `--by` also team, company, user, usageCategory, userPlan, issueCategory, issue, issueDetail |
| `satisfaction [filters]` | The sessions by label, direction and deciding reason |
| `waiting [filters]` | The turns' waiting-time distribution, the slowest answer's spread, by intent |
| `sessions [filters] --all --max N` | The sessions, newest first; `--all` follows the pages |
| `session <id> --format text` | One session as a transcript; `--tool-calls` adds the tool calls' inputs and outputs (read from Langfuse, slow and rate-limited) |
| `findings --last 30d [--team <id>] [--state open\|resolved] [--by day]` | The findings, anomalies saved as a lens on the sessions, with their occurrences in the period, the period before and since their resolution; `--by day` adds them per day, to follow a fix |
| `finding create --title "…" [--description "…"] [filters]` | Saves a finding whose lens is the filters given (not the period), its description in Markdown; `finding <id>` reads one, `finding <id> edit\|resolve\|reopen\|team <id\|none>\|lens [filters]\|delete` changes it as the person's role allows |
| `intents`, `teams`, `people`, `issue-types`, `company-properties` | The registries: also the valid filter values |
| `activity --who <email> --area intents\|failures\|labelling\|access --search <name> --limit N` | Who changed what on the platform, newest first, each entry with what changed from what to what and a `what` line of its records' names; the access area is for project managers and admins |
| `get <path> [name=value …]` | Any `GET` route of the API (`backend/README.md`), for the labelling tasks and the failures |

Filters are the dashboard's, as flags on the commands above: `--last 7d` or `--from 2026-10-13 --to 2026-10-20` (UTC; `to` exclusive; the last 24 hours by default), `--intent <id>` or `other`, `--team <id>` or `none`, `--satisfaction dissatisfied,negative`, `--reason <code>`, `--issue technical|billing|none`, `--issue-code <code>`, `--usage paid,free`, `--user-plan`, `--user-role`, `--upgrade-request`, `--company-country es`, `--company-size`, `--wait 30-,` `--wait-by last`, and `--finding <id>`, which applies a finding's lens under the other filters (a filter the lens sets is refused). `one-metrics help` lists them all with their values.

## Working well

- Keep answers small: `--format tsv` or `jsonl` with `--fields a,b.c`, e.g. `sessions --last 7d --satisfaction dissatisfied --all --max 200 --format tsv --fields sessionId,startedAt,intentId,satisfactionReason,waitSeconds.slowest`. `--format json` without `--fields` is the API's full answer.
- Start wide, then narrow: `summary` and `breakdown --by intent` for the shape of a period, `sessions` with filters for the cases, `session <id> --format text` to read one.
- Dates and ids are the platform's: intent ids from `intents`, issue codes from `issue-types`, company property values from `company-properties`.
- Sessions and transcripts are personal data. Report counts, shares, reasons and outcomes; do not paste users' messages, One's answers, names or emails into chat, files or commits unless the user asks for that specific content.
- Writing a finding: a title of one short line that names the anomaly, and a description in Markdown, which its page renders. Open with what was seen, the numbers with their period and the filters behind them, then why it matters and what a fix looks like, each under a short bold label, with lists for breakdowns. Pass it as `--description "$(cat <<'EOF' … EOF)"` so its lines survive the shell. Counts, tool names and error messages belong in it; users' messages, names and emails do not.
- Only the `finding` command's actions change data, as the signed-in person: `create`, `edit`, `resolve`, `reopen`, `team`, `lens` and `delete`. Run one when the user asks for that change, say what changed, and never delete without their word. Every other command, `get` included, is read-only.
