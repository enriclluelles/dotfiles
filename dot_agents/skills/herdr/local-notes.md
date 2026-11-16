# Herdr local notes

Lessons learned driving Claude Code agents through Herdr.

## Prompt stalls right after `agent start`

`herdr agent start` can report `agent_started` before the agent actually accepts input. The first
`herdr agent prompt ... --wait` may then fail with `agent_prompt_stalled` (status stays `idle`) and the prompt is lost:
the pane shows an empty input box. Check with `herdr pane read <pane> --source visible`, then resend the
prompt once. Sending prompts to several agents at once makes this more likely.

## Collecting answers from agents

- Ask the agent to wrap its answer in unique markers (for example `BRIEF-START` / `BRIEF-END`).
- Read with `herdr pane read <pane> --source recent-unwrapped --lines 200` so soft-wrapped lines are not split.
- The prompt text itself contains the markers, so take the *second* match:
  `awk '/BRIEF-START/{c++} c==2' | sed -n '/BRIEF-START/,/BRIEF-END/p'`.

## Removing worktrees

Use `herdr worktree remove --workspace <id> [--force]` — it closes the panes/workspace and
removes the checkout in one step. Do NOT close the panes first: the workspace auto-closes
when its last pane closes, and then `worktree remove` fails with `workspace_not_found`,
leaving the git checkout to clean up manually. Harvest any generated outputs (work/ dirs,
reports) before removing; `--force` is needed when untracked files exist.

## Fan-out pattern

- Create a workspace: `herdr workspace create --cwd <dir> --label <name> --no-focus`; the root pane is `.result.root_pane.pane_id`.
- Split into a grid: `herdr pane split <pane> --direction right|down --cwd <dir> --no-focus`; the new id is `.result.pane.pane_id`.
- Run commands with `&` + `wait` in bash to start, prompt, or wait on several agents in parallel.
- `herdr agent wait <name> --until idle --until done --until blocked --timeout <ms>` waits for an agent that is already working.

## Focus follows the request

When the user says to do something *in* a herdr workspace, worktree, tab or pane ("in w2Z", "in the
one-workflows worktree", "in that tab"), bring that place into view by default, before or right after
acting there. Only skip it when they say not to ("without switching", "in the background", "keep me here")
or when the work is a pure background read. This overrides the generic "use `--no-focus`" rule in the
generated skill.

- Workspace: `herdr workspace focus <wN>` (use the id from `herdr workspace list`, not the label).
- Tab: `herdr tab focus <wN:tM>`.
- Pane: `herdr pane focus --direction <left|right|up|down> --pane <id>`; it is relative, so focus the
  workspace or tab first and read `herdr pane layout` to pick the direction.
- Creating things there: drop `--no-focus` from `workspace create`, `worktree create`, `pane split`,
  so the new place is focused at once.

Focus moves only the user's view. This agent still runs in its own worktree; execute the work through
`herdr pane run` / `send-text` / `agent prompt` in the target pane, or hand it to an agent there.
