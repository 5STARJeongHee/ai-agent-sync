---
name: sync-dotfiles
description: |
  A skill to synchronize agent configurations (.claude, .gemini, .codex) using chezmoi. 
  Handles remote pull, local apply, and git push operations seamlessly.
  Trigger this when the user asks to "sync settings", "pull latest skills", "update dotfiles", or "push my changes".
---

# sync-dotfiles

This skill manages dotfiles and agent configurations via `chezmoi` across 3 main directions.

## Direction A — Remote → Home Directory (Remote Pull)

Fetches changes pushed by other machines or collaborators from the remote repository.
`chezmoi update` combines `git pull` and `chezmoi apply` into one step.

```sh
# (Optional) Check changes before applying
chezmoi git -- fetch
chezmoi git -- log HEAD..origin/master --oneline

# Pull and apply in one step
chezmoi update
```

## Direction B — Source → Home Directory (Local Apply)

Applies existing changes in the source directory to the home directory.

```sh
SOURCE_DIR=$(chezmoi source-path)

# Check what will be changed
chezmoi diff

# Apply changes
chezmoi apply

# Commit and push changes
cd "${SOURCE_DIR}"
git status
git add -A
git commit -m "chore: update dotfiles"
git push
```

## Direction C — Home Directory → Source (Reverse Sync)

Used when files are modified directly in the home directory and need to be saved to the source repo.

```sh
# Example: re-add modified agent configuration files
# Adjust paths based on the requested files
chezmoi re-add ~/.claude/CLAUDE.md
chezmoi re-add ~/.gemini/GEMINI.md
chezmoi re-add ~/.codex/config.toml

SOURCE_DIR=$(chezmoi source-path)
cd "${SOURCE_DIR}"
git diff
git add -A
git commit -m "chore: re-add modified dotfiles"
git push
```

## Important Notes
- Template files (`.tmpl`) are rendered automatically during `chezmoi apply`.
- Secrets or API keys MUST NEVER be committed to Git. Store them in `~/.config/chezmoi/chezmoi.toml` under `[data]`.
- Warning messages like "config file template has changed" during `chezmoi diff` are generally harmless.
- Do NOT track temporary files, logs, or cache directories (e.g., `~/.claude/cache/`) with chezmoi.
