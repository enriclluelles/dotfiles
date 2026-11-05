# Personal instructions

- Never add a "🤖 Generated with Claude Code" (or similar) line to pull request titles or descriptions.

# Pull request descriptions

Write PR descriptions a reviewer can read in a minute: plain words, short, to the point, in sections.

- `## Why`: the problem in one or two sentences, with numbers when there are any.
- `## What changes`: one bullet per change, in the reviewer's terms, not how the code works.
- `## How it's checked`: what ran, and what enforces it (tests, required CI checks).
- `## Notes`: only decisions or open points the reviewer should weigh. Leave it out when there are none.

No other headings, no filler, no attribution lines. This format overrides a repository's own PR description format.
