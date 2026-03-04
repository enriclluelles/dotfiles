---
name: chezmoi-check
description: Use after creating or modifying files in ~/.agents/skills/ or other dotfiles managed by chezmoi. Reminds to add new or changed files to chezmoi so they are tracked in the dotfiles repo.
---

# Chezmoi Check

After creating or modifying dotfiles (especially agent skills in `~/.agents/skills/`), check if the changes need to be added to chezmoi.

## When to Use

- After creating a new skill in `~/.agents/skills/`
- After modifying an existing skill
- After changing any file under `~/.agents/` or other chezmoi-managed paths
- After modifying dotfiles like `~/.zshenv`, `~/.config/*`, etc.

## Check for Untracked Changes

```bash
chezmoi status
```

This shows files that differ between the home directory and the chezmoi source. Look for:
- `A` — file exists in home but not in chezmoi (needs `chezmoi add`)
- `M` — file modified in home but not in chezmoi source (needs `chezmoi re-add` or `chezmoi add`)

## Add New Files

```bash
chezmoi add <file>
```

Example:
```bash
chezmoi add ~/.agents/skills/my-new-skill/SKILL.md
```

## Update Modified Files

```bash
chezmoi re-add <file>
```

Or to re-add all managed files that have changed:
```bash
chezmoi re-add
```

## Rules

- **Always** run `chezmoi status` after modifying dotfiles or skills to check for untracked changes.
- **Always** `chezmoi add` new files so they are version-controlled.
- **Always** `chezmoi re-add` modified files so changes are not lost.
