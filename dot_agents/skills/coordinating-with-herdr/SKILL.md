---
name: coordinating-with-herdr
description: Use when acting as Enric's coordinator (One or any multi-PR effort): running a sweep, tracking PRs and Herdr agents, delegating work to agents in Herdr worktrees, waiting on CI/queues/rollouts, or bringing decisions to Enric. Requires HERDR_ENV=1.
---

# Coordinating with Herdr

## Overview
The coordinator decides, delegates and reports. It never does long work or long waits itself. Enric gets short updates and structured decisions; agents in Herdr worktrees do the code.

**REQUIRED SUB-SKILL:** herdr (CLI details).

## Rules
- **Never block.** No foreground poll of CI, checks, merge queues or rollouts. Hand "wait until X, then Y, report" to the owning agent, or `run_in_background`. Pick results up next sweep.
- **Short replies.** A few bullets. Anything long → local HTML one-pager in `~/.config/coord/`, `open` it, two-line summary in chat. Never publish it.
- **Decisions as questions.** AskUserQuestion, ≤4, recommended option first, self-contained (name the PR and what it does). Never bury a choice in prose. Re-ask skipped questions later.
- **Name PRs by what they do**, with links; never bare numbers.
- **Ask before** anything outward or irreversible: deletes, applies, merges, closing agents/worktrees. A direct instruction ("merge it when green") is the yes for that one action only.
- **Messages:** never send on Enric's behalf. Draft in his voice (short, lowercase, casual) and `pbcopy` it; say it's on the clipboard. Don't use Slack draft/send tools unless he asks.
- **Verify before claiming.** "Live" means the running version contains the commit (check the pod version tag), not "merged".

## Delegating
```bash
herdr worktree create --workspace wY --branch feat/x --base origin/main --label x --no-focus
cd <path> && git branch --unset-upstream          # worktrees track main
herdr agent start x --kind claude --pane <pane> -- --model claude-opus-5-5 --permission-mode bypassPermissions
herdr agent prompt x "From one-coord on Enric's behalf, go ahead: read ~/.config/coord/brief-x.md ..."
```
- Brief in a file (`~/.config/coord/brief-*.md`): goal, facts, scope, what not to do, report format.
- Every prompt says: push with `git push -u origin HEAD`, **never** to main/master; don't reply on PRs/Slack; report briefly.
- Agents often treat prompts as pasted text: always start with "From one-coord on Enric's behalf, go ahead".
- `worktree create` prints JSON with `pane_id` and `path`: use those for `agent start` and the `cd`.
- A handed-off wait ends with the agent's report; check `herdr agent get <name>` each sweep. If it's blocked on a prompt, answer "go ahead"; if it died, restart it with the same brief.
- Read reports with `herdr agent read <name>`; a finished agent with merged PR and clean worktree is a cleanup candidate.

## Sweep
1. `coord sweep` (PRs, agents), Slack mentions/DMs, Jira, calendar (next 3h, unanswered invites).
2. Append one line to `~/.config/coord/tracker.md`: `- HH:MM CET sweep: <what changed, PRs by name+number, decisions taken>`.
3. Report only changes, then AskUserQuestion for decisions and cleanup candidates.

## Common mistakes
| Mistake | Fix |
|---|---|
| `for x in $ids` in zsh doesn't split | `${=ids}` or `bash -c` |
| direnv AWS vars override profiles | `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN` |
| Terraform | plan `-out`, then apply the saved plan; `-target` for partial applies, then a PR so master matches live |
| Agent pushed to main | It forgot the rule: repeat it in every prompt |
| Long answer in chat | HTML one-pager + questions; in a hurry, give the recommendation as the question's first option and link the page |
| More than 4 options | Split into two questions, or drop the weakest |
