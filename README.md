# AI Agent Sync Plugin

A unified plugin to synchronize your AI agent environments (Claude, Gemini, Codex) across multiple machines using `chezmoi` and `git`.

## What is this?

Managing skills, sub-agents, and plugin configurations consistently across different AI agents and multiple machines is tedious. This plugin teaches each agent how to manage its own environment directly through `chezmoi`.

## Provided Skills

| Skill | Description |
|-------|-------------|
| `sync-dotfiles` | Sync dotfiles and agent settings with a remote git repository |
| `manage-skills` | Add, edit, remove, promote, or demote skills (shared ↔ agent-specific) |
| `list-skills` | List all currently loaded skills per agent |
| `manage-agents` | Add, edit, remove, promote, or demote sub-agents |
| `list-agents` | List sub-agent inventory per agent |
| `manage-plugins` | Add, edit, or remove plugins / MCP servers per agent |
| `list-plugins` | List plugin inventory per agent |

## Installation

See [INSTALL.md](INSTALL.md) for full installation instructions.

## How it works

All changes happen exclusively in the **chezmoi source directory (managed area)**. Editing agent folders in the home directory directly will be overwritten on the next `chezmoi apply`, so skills, agents, and plugins must always be managed through the source directory.

```
[Managed Area — chezmoi source]         [Actual Agent Folders — do not edit directly]

dot_ai-skills/        →  chezmoi apply  →  ~/.ai-skills/
dot_ai-agents/        →  chezmoi apply  →  ~/.ai-agents/
dot_claude/skills/    →  chezmoi apply  →  ~/.claude/skills/
dot_claude/agents/    →  chezmoi apply  →  ~/.claude/agents/
dot_gemini/skills/    →  chezmoi apply  →  ~/.gemini/skills/
dot_gemini/agents/    →  chezmoi apply  →  ~/.gemini/agents/
dot_codex/skills/     →  chezmoi apply  →  ~/.codex/skills/
dot_codex/agents/     →  chezmoi apply  →  ~/.codex/agents/
        ↓
      git push → remote repository → pull on another machine
```

When you change a skill, agent, or plugin, the agent automatically runs `chezmoi apply` and `git push` to completion.

## Plugin Systems by Agent

Each agent has a different plugin mechanism.

| Agent | System | Config Location |
|-------|--------|----------------|
| Claude Code | Marketplace (`enabledPlugins`) | `~/.claude/settings.json` |
| Codex | Marketplace (`[plugins.*]`) | `~/.codex/config.toml` |
| Gemini CLI | Skills directory (auto-scan) | `~/.gemini/skills/` |

## Usage Examples

```
/sync-dotfiles                          → Initialize chezmoi and connect dotfiles repo
"Sync my settings"                      → Pull remote changes and apply to all agents
"List skills"                           → Show skill inventory per agent
"List plugins"                          → Show plugin / MCP server inventory per agent
"Promote the xxx skill to shared"       → Move to ~/.ai-skills/ and deploy to all agents
"Add the ecc plugin"                    → Register ecc marketplace plugin for Claude Code
"Edit the xxx skill"                    → Update skill content in the chezmoi source
"Add cursor to sync targets"            → Extend sync scripts to include a new agent
```

## Directory Structure

```
ai-agent-sync/
├── plugin.json          — Plugin metadata
├── INSTALL.md           — Detailed installation guide (English)
├── INSTALL.ko.md        — Detailed installation guide (Korean)
├── PLUGIN-REGISTRY.md   — Registered plugin registry
├── scripts/
│   ├── run_always_sync-skills.sh    — Auto-distributes common skills on chezmoi apply
│   └── run_always_sync-agents.sh   — Auto-distributes common sub-agents on chezmoi apply
└── skills/
    ├── sync-dotfiles/   — Dotfiles sync, initial setup, scheduler management
    ├── manage-skills/   — Skill management (add, edit, remove, promote, demote)
    ├── list-skills/     — Skill listing
    ├── manage-agents/   — Sub-agent management (add, edit, remove, promote, demote)
    ├── list-agents/     — Sub-agent listing
    ├── manage-plugins/  — Plugin / MCP server management (add, edit, remove)
    └── list-plugins/    — Plugin listing
```

## License

MIT — see [LICENSE](LICENSE).
