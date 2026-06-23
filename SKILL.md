---
name: sync-dotfiles
description: |
  A skill to synchronize agent configurations (.claude, .gemini, .codex) using chezmoi. 
  Handles remote pull, local apply, and git push operations seamlessly.
  Trigger this when the user asks to "sync settings", "pull latest skills", "update dotfiles", or "push my changes".
---

# sync-dotfiles

This skill manages dotfiles and agent configurations via `chezmoi` across 3 main directions.

## Prerequisites Check

Before running any direction, verify chezmoi is installed:

```sh
if ! command -v chezmoi &>/dev/null; then
  echo "chezmoi is required but not installed."
  echo "Install with one of the following:"
  echo "  macOS/Linux/Git Bash: sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- -b ~/bin"
  echo "  Windows (PowerShell): winget install twpayne.chezmoi"
  exit 1
fi
```

If not installed, stop immediately and show the install command. Do not proceed with sync.

Also verify chezmoi has been initialized (a source directory exists):

```sh
if ! chezmoi source-path &>/dev/null 2>&1; then
  echo "chezmoi is not initialized yet."
  echo "Run: chezmoi init --apply <your-repo-url>"
  exit 1
fi
```

If not initialized, stop and ask the user for their dotfiles repository URL, then run `chezmoi init --apply <url>`.

## Skill Distribution Architecture

Common skills use a hub-and-spoke model. All agents receive the same skills automatically:

```
dotfiles repo
├── dot_ai-skills/          ← common skill hub
│   └── <skill-name>/
│       └── SKILL.md
├── dot_claude/skills/      ← Claude-only skills
├── dot_gemini/skills/      ← Gemini-only skills
└── run_always_sync-skills.sh  ← auto-runs on every chezmoi apply
```

On every `chezmoi apply` or `chezmoi update`, `run_always_sync-skills.sh` copies all skills from `~/.ai-skills/` into each agent's `skills/` directory automatically. No manual `chezmoi add` per agent needed.

To integrate into your dotfiles repo:
```sh
SOURCE_DIR=$(chezmoi source-path)
cp run_always_sync-skills.sh "${SOURCE_DIR}/"
cp run_once_setup-auto-update.sh "${SOURCE_DIR}/"
chezmoi apply
```

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

Used in two cases:
1. **First-time registration** — registering agent skill directories with chezmoi for the first time
2. **Modified files** — files edited directly in the home directory that need to be saved back to the source repo

### Case 1: First-time registration of agent skill directories

Run this once on the primary machine to start tracking agent configurations:

```sh
# Register skill directories for each agent you use
chezmoi add ~/.claude/skills/
chezmoi add ~/.claude/CLAUDE.md

chezmoi add ~/.gemini/skills/         # if using Gemini
chezmoi add ~/.gemini/GEMINI.md       # if using Gemini

chezmoi add ~/.codex/skills/          # if using Codex

SOURCE_DIR=$(chezmoi source-path)
cd "${SOURCE_DIR}"
git add -A
git commit -m "chore: register agent skill directories"
git push
```

After this, other machines can receive all skills automatically via `chezmoi init --apply <repo-url>`.

### Case 2: Re-add modified files

When specific files were edited directly in the home directory:

```sh
# Re-add only the changed files
chezmoi re-add ~/.claude/CLAUDE.md
chezmoi re-add ~/.gemini/GEMINI.md

SOURCE_DIR=$(chezmoi source-path)
cd "${SOURCE_DIR}"
git diff
git add -A
git commit -m "chore: re-add modified dotfiles"
git push
```

### Case 3: New skill added to an agent

When a new skill file was placed directly into an agent's skills directory:

```sh
# Register the new skill file with chezmoi
chezmoi add ~/.claude/skills/<new-skill-name>.md

SOURCE_DIR=$(chezmoi source-path)
cd "${SOURCE_DIR}"
git add -A
git commit -m "chore: add <new-skill-name> skill"
git push
```

## Auto-Update Scheduler

To sync automatically on every login without manual intervention:

```sh
# Register the scheduler (runs once per machine via run_once_ prefix)
SOURCE_DIR=$(chezmoi source-path)
sh "${SOURCE_DIR}/run_once_setup-auto-update.sh"
```

This registers:
- **Windows**: Task Scheduler (`chezmoi-auto-update`) to run `chezmoi update` at login
- **Linux/macOS**: crontab `@reboot` entry

Verify registration:
```sh
# Windows
schtasks /Query /TN "chezmoi-auto-update"

# Linux/macOS
crontab -l | grep chezmoi
```

## Important Notes
- Template files (`.tmpl`) are rendered automatically during `chezmoi apply`.
- Secrets or API keys MUST NEVER be committed to Git. Store them in `~/.config/chezmoi/chezmoi.toml` under `[data]`.
- Warning messages like "config file template has changed" during `chezmoi diff` are generally harmless.
- Do NOT track temporary files, logs, or cache directories (e.g., `~/.claude/cache/`) with chezmoi.
