# Global Agent Instructions

## Python
Anything that runs Python must use `uv`. Create environments with `uv venv`, install with `uv pip install` (or `uv add` in a uv project), and run scripts with `uv run`. Do not use `python -m venv`, `virtualenv`, `source .venv/bin/activate`, bare `python`/`pip`, `pip install --user`, or conda.

## Delegation
Before starting a multi-step task, check whether any part is self-contained (needs no conversation history) and mechanical enough to hand to a cheaper agent with a small fresh context (bulk edits, path fixes, downloads of a known list, checklists). If so, use the delegating-simple-tasks skill and follow its threshold; if not, just do the work.
