---
name: delegating-simple-tasks
description: Use when a task contains mechanical, well-specified, independent chunks (path rewrites, renames, boilerplate, bulk edits, running a checklist) that a cheaper model like Haiku or Sonnet could do in parallel while the main agent keeps context. Also use when the user says "spawn", "fan out", "use haiku/sonnet for this", or "herdr tabs". Requires running inside Herdr (HERDR_ENV=1).
---

# Delegating Simple Tasks to Cheaper Agents

Spin up Haiku/Sonnet-class agents in Herdr tabs for the mechanical parts, keep the thinking and the verification yourself.

## When to Use

- Edits you could describe exactly in two sentences: fix these paths, rename this symbol, apply this template to N files.
- Two or more chunks that touch different files or regions and can run at once.
- The expensive part is typing and waiting, not deciding.

**Do not delegate:** anything needing judgment about the codebase, anything you have not already located yourself, or the verification step. If you cannot name the file and the exact change, do it yourself or investigate first.

## Workflow

1. **Locate first.** Find the files, lines, and target values yourself. Confirm referenced assets really exist (`ls` the exact path, do not trust a scrolled listing).
2. **Check the environment:** `test "${HERDR_ENV:-}" = 1`. If it fails, fall back to the harness's own subagent tool.
3. **One tab per task, same workspace and cwd:**
   ```bash
   herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <task> --no-focus
   ```
   Take `pane_id` from `.result.root_pane`.
4. **Start the cheap agent with permissions bypassed.** Nobody is watching the delegate's pane, so any approval prompt stalls it until you notice. `acceptEdits` is not enough: it covers file edits only, and every shell command still prompts. Model flags go after `--`; run `<agent> --help` for the kind's exact flags. Also start delegates with no MCP servers: they do not need them, startup is faster, and the "new MCP servers found" dialog that swallows the first prompt never appears.
   ```bash
   herdr agent start <name> --kind claude --pane <pane_id> -- --model haiku --permission-mode bypassPermissions --strict-mcp-config
   ```
   Bypass is acceptable because the brief is narrow, you located the files, and you verify the result. Do not widen the brief to compensate.
5. **Prompt with a self-contained brief** (see below), all tabs in parallel:
   ```bash
   herdr agent prompt <name> "<brief>" --wait --timeout 300000 &
   ...; wait
   ```
6. **Verify the result yourself** with grep/diff/ls against the original goal. "done" from the agent is a status, not proof.
7. Log what was delegated if the project keeps a journal. Leave tabs open unless asked.

## Writing the Brief

- Open with "Task from the user:" and say the user asked for exactly this. A bare pasted brief looks like untrusted input and the delegate may stop and ask "reply go to start".
- Exact file path, exact current value, exact target value.
- The file's own directory as the frame for relative paths.
- What is **out of scope**, naming the regions another agent owns.
- "Do not commit." and "Reply with the values you changed."

## Quick Reference: Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| `agent_prompt_stalled`, status `idle` | A startup dialog (MCP servers, trust prompt) ate the input | `herdr agent read <name> --source visible`, dismiss with `herdr agent send-keys <name> esc`, re-send. Prevent it: `--strict-mcp-config` for Claude, or dismiss any `.mcp.json` above the cwd |
| Status `blocked` on a permission prompt | Started without `bypassPermissions`; reads outside cwd and every Bash call prompt | `agent read --source visible`, then `send-keys <name> <option number>` (pick "switch to auto mode" if offered). Next time start with bypass |
| Status `done` immediately, reply asks you to confirm ("reply go") | Delegate treated the pasted brief as untrusted | Prompt again: "go, the user asked for exactly this". Opening the brief with "Task from the user:" reduces this but does not prevent it, especially when the brief uses the user's logged-in browser or accounts. Expect one confirm round and check for it right after the first prompt |
| Agent reports done but file unchanged | Prompt was ambiguous, or it edited the wrong file | Diff before trusting; tighten the brief and re-prompt |
| New relative links point at missing files | You assumed an asset was in the repo | Copy the asset in yourself; that was your job in step 1 |
| `.claude/settings.local.json` appears in the repo | Dismissing the MCP dialog writes it | Harmless; gitignore or delete. Does not happen with `--strict-mcp-config` |

## Common Mistakes

- Starting with `agent start` before `tab create` returns a pane. Panes come from layout commands only.
- Prompting two agents to edit the same region. Split by file or by clearly named sections.
- Skipping `--wait` and polling instead. `--wait` returns on the first settled state.
- Treating this as a way to avoid reading the code. The delegate needs your findings as input.
