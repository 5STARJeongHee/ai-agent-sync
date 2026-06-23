# AI Agent Sync Plugin

A unified plugin to synchronize your AI agent environments (Claude, Gemini, Codex) across multiple machines using `chezmoi` and `git`.

## What is this?

Managing custom skills, prompts, and configurations across different AI agents and multiple machines can be tedious. This plugin solves this by teaching your AI agent how to automatically manage its own environment using `chezmoi`.

## Prerequisites

- **git** — version control for your dotfiles repository
- **bash** (or zsh, Git Bash on Windows) — to run the setup script
- **curl** — for automatic chezmoi installation (if not already installed)
- A **GitHub** (or other git host) account with an empty repository ready

## Quick Start

### 1. Setup (For Humans)

First, create a blank git repository on GitHub (e.g., `agent_settings`) to store your agent settings.

Then run the setup script:

```bash
bash scripts/setup.sh
```

The script will:
1. Install `chezmoi` if it is not already present (macOS, Linux, Git Bash on Windows)
2. Skip initialization if `chezmoi` is already configured on this machine
3. Prompt for your repository URL and run `chezmoi init --apply`

> **Windows users:** The script works in **Git Bash**. If you prefer PowerShell, install chezmoi first with `winget install twpayne.chezmoi`, then run the script in Git Bash.

### 2. Add the ignore list to your dotfiles repo (Optional but recommended)

Copy `templates/.chezmoiignore` into the root of your chezmoi source directory to exclude AI agent cache and secret files from being tracked:

```bash
cp templates/.chezmoiignore "$(chezmoi source-path)/.chezmoiignore"
chezmoi apply
```

> Note: `setup.sh` does **not** place this file automatically. It is a reference template you copy manually.

### 3. Usage (For AI Agents)

Install `SKILL.md` into your agent's skills directory. You can then ask your AI:

- "Sync your settings"
- "Update your skills from remote"
- "Push my latest modifications to git"

The agent will run the appropriate `chezmoi` commands and handle git operations seamlessly.

## Directory Structure

- `SKILL.md` — Core prompt instructions for the AI agent
- `scripts/setup.sh` — Interactive bootstrapping script for new environments
- `templates/.chezmoiignore` — Reference ignore list for AI agent cache/secret files (copy to your dotfiles repo)
- `LICENSE` — MIT License

## License

MIT — see [LICENSE](LICENSE).
