# Personal instructions

- Never add a "🤖 Generated with Claude Code" (or similar) line to pull request titles or descriptions.

# Pull request descriptions

Write PR descriptions a reviewer can read in a minute: plain words, short, to the point, in sections.

- `## Why`: the problem in one or two sentences, with numbers when there are any.
- `## What changes`: one bullet per change, in the reviewer's terms, not how the code works.
- `## How it's checked`: what ran, and what enforces it (tests, required CI checks).
- `## Notes`: only decisions or open points the reviewer should weigh. Leave it out when there are none.

No other headings, no filler, no attribution lines. This format overrides a repository's own PR description format.

# Replies and decisions

- Keep replies short by default: a few lines or bullets. No long paragraphs unless asked.
- If an answer needs to be long (a report, plan, comparison or explainer), write a local one-page HTML file and open it, with a two-line summary in chat. Local only, never published.
- Distill every choice the user has to make into a structured question (AskUserQuestion, or the harness equivalent): at most 4, recommended option first, each self-contained. Do not bury decisions in prose.
