# AI Agent Sync Plugin

A unified plugin to synchronize your AI agent environments (Claude, Gemini, Codex) across multiple machines using `chezmoi` and `git`.

## What is this?

Managing custom skills, prompts, and configurations across different AI agents and multiple machines can be tedious. This plugin solves this by teaching your AI agent how to automatically manage its own environment using `chezmoi`.

## Installation

Copy `SKILL.md` into your agent's skills directory:

```bash
# Claude Code
cp SKILL.md ~/.claude/skills/sync-dotfiles.md

# Gemini
cp SKILL.md ~/.gemini/skills/sync-dotfiles.md
```

That's it. The skill handles everything else when you first use it.

## Usage

Once installed, ask your AI agent:

- "Sync your settings"
- "Pull the latest skills from remote"
- "Push my changes to git"

On first use, the agent will check if `chezmoi` is installed and initialized, and guide you through setup if needed.

## Prerequisites

The skill checks these automatically on first run:

- **chezmoi** — install with `sh -c "$(curl -fsLS get.chezmoi.io)"` or `winget install twpayne.chezmoi`
- **git** — must be available in your PATH
- A **git repository** to store your dotfiles (e.g., GitHub)

## Optional: Automated Setup Script

If you prefer to set up chezmoi manually before using the skill, run:

```bash
bash scripts/setup.sh
```

This installs chezmoi (if missing) and connects your dotfiles repository in one step. It is safe to run multiple times — it skips initialization if chezmoi is already configured.

## Optional: Ignore Template

Copy `templates/.chezmoiignore` into your chezmoi source directory to exclude AI agent cache and secret files from being tracked:

```bash
cp templates/.chezmoiignore "$(chezmoi source-path)/.chezmoiignore"
chezmoi apply
```

## Directory Structure

- `SKILL.md` — Core prompt instructions for the AI agent
- `scripts/setup.sh` — Optional one-shot setup helper
- `templates/.chezmoiignore` — Reference ignore list for agent cache/secrets
- `LICENSE` — MIT License

## License

MIT — see [LICENSE](LICENSE).
