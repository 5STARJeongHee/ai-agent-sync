# AI Agent Sync Plugin

A unified plugin to synchronize your AI agent environments (Claude, Gemini, Codex) across multiple machines using `chezmoi` and `git`.

## What is this?

Managing custom skills, prompts, and configurations across different AI agents and multiple machines can be tedious. This plugin solves this by teaching your AI agent how to automatically manage its own environment using `chezmoi`.

## How it works

Common skills live in a single hub (`~/.ai-skills/`) and are automatically distributed to all agents on every `chezmoi apply`:

```
dotfiles repo (GitHub)
├── dot_ai-skills/              ← common skill hub → all agents
│   └── sync-dotfiles/
│       └── SKILL.md
├── dot_claude/skills/          ← Claude-only skills
├── dot_gemini/skills/          ← Gemini-only skills
├── run_always_sync-skills.sh   ← auto-runs on every chezmoi apply
└── run_once_setup-auto-update.sh ← registers login auto-sync (once per machine)
```

## Installation

### Step 1 — Copy SKILL.md to your agent

```bash
# Claude Code
cp SKILL.md ~/.claude/skills/sync-dotfiles.md

# Gemini
cp SKILL.md ~/.gemini/skills/sync-dotfiles.md
```

### Step 2 — Ask the agent to set up

```
"초기 설정해줘" / "set up for the first time"
```

The agent will automatically:
1. Check if `chezmoi` is installed and initialized (and guide you if not)
2. Download `run_always_sync-skills.sh` and `run_once_setup-auto-update.sh` into your dotfiles repo
3. Register this skill in the common skill hub (`~/.ai-skills/sync-dotfiles/`)
4. Run `chezmoi apply` and push to git

After this, every future `chezmoi update` distributes all skills to every agent automatically.

### Step 3 — Use

Ask your AI agent:
- "Sync your settings" → pulls remote changes and distributes to all agents
- "Push my changes" → commits and pushes local changes to git
- "Update your skills from remote" → same as sync

## New machine setup

```bash
# 1. Install agent (Claude / Gemini / etc.)
# 2. Copy SKILL.md into the agent's skills directory (this step)
cp SKILL.md ~/.claude/skills/sync-dotfiles.md

# 3. Ask the agent to sync — it will run:
chezmoi init --apply <your-repo-url>
# → All skills, configs, and auto-update scheduler are deployed automatically
```

## Prerequisites

The skill checks these automatically on first run:

- **chezmoi** — install with `sh -c "$(curl -fsLS get.chezmoi.io)"` or `winget install twpayne.chezmoi`
- **git** — must be available in your PATH
- A **git repository** to store your dotfiles (e.g., GitHub)

## Optional: Automated Setup Script

If you prefer to bootstrap chezmoi manually before using the skill:

```bash
bash scripts/setup.sh
```

This installs chezmoi (if missing) and connects your dotfiles repository in one step. Safe to run multiple times.

## Optional: Ignore Template

Copy `templates/.chezmoiignore` into your chezmoi source directory to exclude AI agent cache and secret files:

```bash
cp templates/.chezmoiignore "$(chezmoi source-path)/.chezmoiignore"
chezmoi apply
```

## Directory Structure

- `SKILL.md` — Core prompt instructions for the AI agent
- `scripts/setup.sh` — Optional one-shot bootstrap helper
- `scripts/run_always_sync-skills.sh` — Distributes common skills to all agents on every chezmoi apply
- `scripts/run_once_setup-auto-update.sh` — Registers login auto-sync scheduler (once per machine)
- `templates/.chezmoiignore` — Reference ignore list for agent cache/secrets
- `LICENSE` — MIT License

## License

MIT — see [LICENSE](LICENSE).
