# Installation Guide

Install this plugin through each agent's plugin system, then run `/sync-dotfiles` to complete the chezmoi initial setup.

---

## Table of Contents

- [Claude Code](#claude-code)
- [Gemini CLI / Antigravity](#gemini-cli--antigravity)
- [Codex](#codex)
- [Initial Setup](#initial-setup)
- [Adding a New Agent](#adding-a-new-agent)
- [Available Skills](#available-skills)

---

## Claude Code

### 1. Add marketplace

```
/plugin marketplace add https://github.com/5STARJeongHee/ai-agent-sync.git
```

### 2. Install plugin

```
/plugin install ai-agent-sync@ai-agent-sync
```

`enabledPlugins` is automatically configured by `/sync-dotfiles` during initial setup.

<details>
<summary>Manual installation</summary>

Add the following to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "ai-agent-sync": {
      "source": {
        "source": "git",
        "url": "https://github.com/5STARJeongHee/ai-agent-sync.git"
      }
    }
  },
  "enabledPlugins": {
    "ai-agent-sync@ai-agent-sync": true
  }
}
```

</details>

---

## Gemini CLI / Antigravity

Gemini CLI automatically scans the Skills directory. Cloning into the directory is all that's needed.

```sh
mkdir -p ~/.gemini/skills
git clone https://github.com/5STARJeongHee/ai-agent-sync.git \
  ~/.gemini/skills/ai-agent-sync
```

No additional configuration required — `~/.gemini/skills/` is auto-detected.

---

## Codex

### 1. Add marketplace

```sh
codex plugin marketplace add 5STARJeongHee/ai-agent-sync
```

### 2. Install plugin

```sh
codex plugin install ai-agent-sync@ai-agent-sync
```

Codex installs plugins to `~/.codex/plugins/cache/<marketplace>/<plugin>/<version>` and records activation in `config.toml`:

```toml
[plugins."ai-agent-sync@ai-agent-sync"]
enabled = true
```

<details>
<summary>Manual installation</summary>

```sh
git clone https://github.com/5STARJeongHee/ai-agent-sync.git \
  ~/.codex/plugins/ai-agent-sync
```

Add the following to `~/.codex/config.toml`:

```toml
[marketplaces.ai-agent-sync]
source = "github.com/5STARJeongHee/ai-agent-sync"

[plugins."ai-agent-sync@ai-agent-sync"]
enabled = true
```

</details>

---

## Initial Setup

After installation, run the following in your agent:

```
/sync-dotfiles
```

The `sync-dotfiles` skill will automatically:

1. Check and install `chezmoi` if not present
2. Initialize chezmoi or connect to an existing dotfiles repository
3. Configure common skill and sub-agent directories
4. Verify and apply `enabledPlugins` in Claude `settings.json`
5. Register the login-time auto-sync scheduler

---

## Adding a New Agent

The sync scripts distribute common skills and sub-agents to `.claude`, `.gemini`, and `.codex` by default. To include a new agent, ask your agent:

> "Add `.<new-agent>` to sync targets."

The `sync-dotfiles` skill will update `AGENT_DIRS` in both sync scripts and run `chezmoi apply` automatically.

---

## Available Skills

After installation, make requests in natural language.

| Feature | Example |
|---------|---------|
| List skills | "List skills" |
| Add skill | "Create a new skill" |
| Edit skill | "Edit the xxx skill" |
| Promote skill | "Promote the xxx skill to shared" |
| Demote skill | "Demote the xxx skill to Claude only" |
| Remove skill | "Delete the xxx skill" |
| List sub-agents | "List agents" |
| Add sub-agent | "Create a new agent" |
| Edit sub-agent | "Edit the xxx agent" |
| Promote / demote sub-agent | "Promote the xxx agent to shared" |
| List plugins | "List plugins" |
| Add plugin | "Add the ecc plugin" |
| Edit plugin | "Edit the xxx plugin settings" |
| Remove plugin | "Remove the xxx plugin" |
| Sync settings | "Sync my settings" |
| Add new agent to sync | "Add cursor to sync targets" |
