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

## Fan-out pattern

- Create a workspace: `herdr workspace create --cwd <dir> --label <name> --no-focus`; the root pane is `.result.root_pane.pane_id`.
- Split into a grid: `herdr pane split <pane> --direction right|down --cwd <dir> --no-focus`; the new id is `.result.pane.pane_id`.
- Run commands with `&` + `wait` in bash to start, prompt, or wait on several agents in parallel.
- `herdr agent wait <name> --until idle --until done --until blocked --timeout <ms>` waits for an agent that is already working.
