# AI Agent Sync Plugin

A unified **Plugin** to synchronize your AI agent environments (Claude, Gemini, Codex) across multiple machines using `chezmoi` and `git`.

## What is this?

Managing custom skills, prompts, and configurations across different AI agents and multiple machines can be tedious. This plugin solves this by teaching your AI agent how to automatically manage its own environment using `chezmoi`.

By installing this plugin, your agent gains the following skills:
- `sync-dotfiles`: Syncs your dotfiles and agent settings with a remote git repository.
- `manage-skills`: Adds, removes, promotes, or demotes skills across your agents.
- `manage-agents`: Adds, removes, or modifies sub-agents.
- `list-skills`: Lists all currently loaded skills.

## Installation

You can install this plugin into your preferred AI agent by simply cloning this repository into the agent's plugin directory.

### For Claude (ecc)
```bash
git clone https://github.com/YOUR_USERNAME/ai-agent-sync.git ~/.claude/plugins/ai-agent-sync
```
*(Or use `ecc install` if published to the ecc marketplace)*

### For Gemini (Antigravity)
```bash
git clone https://github.com/YOUR_USERNAME/ai-agent-sync.git ~/.gemini/config/plugins/ai-agent-sync
```

### For Codex
```bash
git clone https://github.com/YOUR_USERNAME/ai-agent-sync.git ~/.codex/plugins/ai-agent-sync
```

## How it works

After installing the plugin, the AI agent will manage your personal `Agent Setting Repo` (your dotfiles repository). 
When you use the skills provided by this plugin, the agent will:
1. Maintain common skills in a single hub (`~/.ai-skills/`) and common agents in (`~/.ai-agents/`).
2. Run `chezmoi apply` to automatically distribute these common skills/agents to all of your installed agents.
3. Push the changes to your remote Git repository.

## Usage

Simply ask your AI agent:
- "초기 설정해줘" / "set up for the first time" (To initialize chezmoi and your dotfiles repo)
- "Sync your settings" → pulls remote changes and distributes to all agents
- "Push my changes" → commits and pushes local changes to git
- "스킬 목록 보여줘" / "List skills" → Lists all available skills across agents
- "새 스킬 만들어줘" / "Create a new skill" → Helps you create and sync a new skill

## Directory Structure

- `plugin.json` — Plugin metadata for Vibe Index and agent marketplaces
- `skills/` — The collection of skills provided by this plugin (sync-dotfiles, manage-skills, etc.)
- `scripts/` — Helper scripts that the agent injects into your dotfiles to auto-run on `chezmoi apply`
- `templates/` — Reference templates and ignore lists
- `LICENSE` — MIT License

## License

MIT — see [LICENSE](LICENSE).
