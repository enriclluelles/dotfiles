---
name: use-ripgrep
description: Always use ripgrep (rg) instead of grep when searching code or text files.
---

# Use ripgrep

Always use `rg` (ripgrep) instead of `grep` when searching through code or text files.

## Rules

- **Never** use `grep -r`, `grep -rn`, or similar recursive grep commands
- **Always** use `rg` which is faster, respects `.gitignore`, and skips binary files by default
- Use `-t` for file type filters instead of `--include`: e.g. `rg "pattern" -t ts` not `grep -rn "pattern" --include="*.ts"`
- Use `-l` to list matching files only (like `grep -rl`)
- Use `-n` for line numbers (on by default in rg)
- Use `-g` for glob patterns: `rg "pattern" -g "*.yml"`
- Use `--no-ignore` if you need to search files excluded by `.gitignore`

## Common translations

| grep | rg |
|---|---|
| `grep -rn "foo" src/ --include="*.ts"` | `rg "foo" src/ -t ts` |
| `grep -rl "foo" .` | `rg -l "foo"` |
| `grep -rn "foo" --include="*.ts" -l` | `rg "foo" -t ts -l` |
| `grep -c "foo" file` | `rg -c "foo" file` |
| `grep -A5 "foo" file` | `rg -A5 "foo" file` |
| `grep -B3 -A3 "foo" dir/` | `rg -B3 -A3 "foo" dir/` |
