---
name: delegating-simple-tasks
description: Use when a self-contained chunk of a task, one that does not need the conversation history, involves repetitive or bulk work across several files or items (3+ similar edits, path fixes, renames, applying a template, reformatting, updating many references), downloading or fetching a known list of things (photos, pages, product images), or running a checklist; or when the user says "spawn", "fan out", "delegate", "use haiku/sonnet" or "herdr tabs". Not for single edits, design, writing, or work not yet located. Requires Herdr (HERDR_ENV=1).
---

# Delegating Simple Tasks to Cheaper Agents

Spin up Haiku/Sonnet-class agents in Herdr tabs for the mechanical parts, keep the thinking and the verification yourself.

**Core test: does the chunk need this conversation's context?** A fresh delegate only carries the brief, a few hundred tokens instead of your whole context, so every turn it takes is far cheaper than yours. If the chunk can be fully described in one self-contained paragraph without the history, hand it off. If it depends on what was discussed, decided or seen earlier, keep it.

## When to Use

- Edits you could describe exactly in two sentences: fix these paths, rename this symbol, apply this template to N files.
- Two or more chunks that touch different files or regions and can run at once.
- The expensive part is typing and waiting, not deciding.

**Threshold:** delegate when it saves real effort: 3+ independent chunks, or one mechanical job of more than ~5 minutes. Below that, do it yourself; spawning and verifying costs more than it saves. At most 2–3 delegates at once.

**Check before every multi-step task:** is any part mechanical enough to hand off? Ask once, answer honestly, move on.

**Do not delegate:** anything needing judgment about the codebase, anything you have not already located yourself, or the verification step. If you cannot name the file and the exact change, do it yourself or investigate first.

## Workflow

1. **Locate first.** Find the files, lines, and target values yourself. Confirm referenced assets really exist (`ls` the exact path, do not trust a scrolled listing).
2. **Check the environment:** `test "${HERDR_ENV:-}" = 1`. If it fails, fall back to the harness's own subagent tool.
3. **One tab per task, same workspace and cwd:**
   ```bash
   herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label <task> --no-focus
   ```
   Take `pane_id` from `.result.root_pane`. Always use your own trusted cwd, never the session scratchpad or another fresh directory: Claude shows a "do you trust this folder?" dialog in any new directory, which blocks `agent start`. Give scratch paths inside the brief instead. With bypass permissions the delegate can still write there.
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

## Choosing the Model and Timebox

| Work | Model | Timebox |
|---|---|---|
| Exact text edits, renames, path fixes | haiku | 1–2 min |
| Anything with a browser, shell exploration, or reading a page/DOM | sonnet | 1–3 min |
| Needs judgment or design | none: do it yourself | — |

Always state the timebox in the brief ("HARD TIMEBOX: N minutes, then stop and report what blocked you"). If a delegate fails once, re-brief once with a tighter method or a stronger model; after a second failure, do it yourself.

## Browser Delegates

- Drive the user's real logged-in browser over CDP with Playwright (`connect_over_cdp`). Launch it with `--remote-debugging-port` on the right profile. Never use a browser extension and never copy or clone a profile.
- Give the delegate the method, not just the goal: which page, which selector to collect, which keyboard shortcut or request triggers the download, and where to save.
- Keep the working script in a stable scratch dir and point later delegates at it, so they reuse it instead of rediscovering the page.
- Record the method in the project journal so the next session doesn't have to dig.

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
| `agent_not_ready` from `agent start`, screen shows "Is this a project you created or one you trust?" | The tab's cwd is a directory Claude has never opened, such as the scratchpad | Recreate the tab with `--cwd "$PWD"` and pass scratch paths in the brief. In a pinch, send `down`, then `enter`, to trust it |
| Status `blocked` on a permission prompt | Started without `bypassPermissions`; reads outside cwd and every Bash call prompt | `agent read --source visible`, then `send-keys <name> <option number>` (pick "switch to auto mode" if offered). Next time start with bypass |
| Status `done` immediately, reply asks you to confirm ("reply go") | Delegate treated the pasted brief as untrusted | Prompt again: "go, the user asked for exactly this". Opening the brief with "Task from the user:" reduces this but does not prevent it, especially when the brief uses the user's logged-in browser or accounts. Expect one confirm round and check for it right after the first prompt |
| Agent reports done but file unchanged | Prompt was ambiguous, or it edited the wrong file | Diff before trusting; tighten the brief and re-prompt |
| New relative links point at missing files | You assumed an asset was in the repo | Copy the asset in yourself; that was your job in step 1 |
| Your background `agent prompt --wait` dies with exit 144 | The delegate ran `pkill -f <pattern>` and the pattern also matched your own waiting shell, whose command line contains the brief text | Give the delegate a PID file or port to kill by, never a string that also appears in your brief |
| Browsing delegate hits a CAPTCHA or "Verification Required" | Fresh or automated browser profile flagged by the site's bot protection | Delegates must not bypass it. Use the user's real logged-in profile, or ask the user to open the page and share screenshots |
| Delegate flounders for minutes on a browser task | Model too weak, or brief gave a goal without a method | Kill it, restart on sonnet with the selector/shortcut spelled out and a timebox |
| "Skip files that already exist" re-downloads everything | Real filenames are only known after the download starts | Let it download to a temp dir, dedupe yourself by filename and checksum |
| `.claude/settings.local.json` appears in the repo | Dismissing the MCP dialog writes it | Harmless; gitignore or delete. Does not happen with `--strict-mcp-config` |

## Common Mistakes

- Starting with `agent start` before `tab create` returns a pane. Panes come from layout commands only.
- Prompting two agents to edit the same region. Split by file or by clearly named sections.
- Skipping `--wait` and polling instead. `--wait` returns on the first settled state.
- Treating this as a way to avoid reading the code. The delegate needs your findings as input.
