---
name: sync-dotfiles
description: |
  A skill to synchronize agent configurations (.claude, .gemini, .codex) using chezmoi. 
  Handles remote pull, local apply, and git push operations seamlessly.
  Trigger this when the user asks to "sync settings", "pull latest skills", "update dotfiles", or "push my changes".
  Also trigger when the user asks to "set up for the first time", "integrate scripts", or "초기 설정해줘".
  Also trigger when the user asks to "check scheduler", "re-register scheduler", "disable auto-sync",
  "스케줄러 상태 확인", "스케줄러 재등록", "자동 동기화 끄기" or similar.
  Also trigger when the user asks to "list sub-agents", "add sub-agent", "remove sub-agent",
  "promote sub-agent", "demote sub-agent", "sub-agent 목록", "sub-agent 추가",
  "sub-agent 제거", "sub-agent 승격", "sub-agent 강등" or similar.
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

## First-time Integration

Trigger when the user says "set up for the first time", "integrate scripts", "초기 설정해줘", or similar.

Run the Prerequisites Check first. If chezmoi is not initialized, ask for the dotfiles repo URL and run `chezmoi init --apply <url>` before proceeding.

### Step 1 — Download auto-sync scripts into the dotfiles repo

```sh
SOURCE_DIR=$(chezmoi source-path)

BASE_URL="https://raw.githubusercontent.com/5STARJeongHee/ai-agent-sync/main/scripts"

curl -fsSL "${BASE_URL}/run_always_sync-skills.sh"  -o "${SOURCE_DIR}/run_always_sync-skills.sh"
curl -fsSL "${BASE_URL}/run_always_sync-agents.sh"  -o "${SOURCE_DIR}/run_always_sync-agents.sh"
curl -fsSL "${BASE_URL}/run_once_setup-auto-update.sh" -o "${SOURCE_DIR}/run_once_setup-auto-update.sh"

chmod +x "${SOURCE_DIR}/run_always_sync-skills.sh"
chmod +x "${SOURCE_DIR}/run_always_sync-agents.sh"
chmod +x "${SOURCE_DIR}/run_once_setup-auto-update.sh"
```

### Step 2 — Set up the common skill hub and register this skill

```sh
mkdir -p "${SOURCE_DIR}/dot_ai-skills/sync-dotfiles"

curl -fsSL "https://raw.githubusercontent.com/5STARJeongHee/ai-agent-sync/main/SKILL.md" \
  -o "${SOURCE_DIR}/dot_ai-skills/sync-dotfiles/SKILL.md"
```

### Step 3 — Apply and push

Before pushing, verify git remote is configured:

```sh
cd "${SOURCE_DIR}"

if ! git remote get-url origin &>/dev/null 2>&1; then
  echo "No git remote 'origin' found."
  echo "Please create a repository and run:"
  echo "  git remote add origin https://github.com/<user>/<repo>.git"
  echo "Then re-run this step."
  exit 1
fi

chezmoi apply

git add -A
git commit -m "feat: integrate ai-agent-sync plugin"
git push
```

If `git push` fails because the remote branch does not exist yet, run:

```sh
git push -u origin main
```

After this, every future `chezmoi apply` or `chezmoi update` will:
1. Automatically distribute all skills in `~/.ai-skills/` to every agent
2. Run the login auto-sync scheduler registration (once per machine)

## Skill Distribution Architecture

Common skills use a hub-and-spoke model. All agents receive the same skills automatically:

```
dotfiles repo
├── dot_ai-skills/              ← common skill hub
│   └── <skill-name>/SKILL.md
├── dot_ai-agents/              ← common sub-agent hub
│   └── <name>.md
├── dot_claude/skills/          ← Claude-only skills
├── dot_claude/agents/          ← Claude-only sub-agents
├── dot_gemini/skills/          ← Gemini-only skills
├── dot_gemini/agents/          ← Gemini-only sub-agents
├── run_always_sync-skills.sh   ← auto-runs on every chezmoi apply
└── run_always_sync-agents.sh   ← auto-runs on every chezmoi apply
```

On every `chezmoi apply` or `chezmoi update`:
- `run_always_sync-skills.sh` copies all skills from `~/.ai-skills/` to each agent's `skills/` directory
- `run_always_sync-agents.sh` copies all sub-agents from `~/.ai-agents/` to each agent's `agents/` directory

No manual `chezmoi add` per agent needed.

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

## Sub-Agent Management

Manages sub-agents across all AI agents (Claude, Gemini, Codex). All three agents use the same `.md` format, so common sub-agents work universally.

Trigger when the user asks to list, add, remove, promote, or demote sub-agents.

### Sub-agent file format

When creating a new sub-agent file, use this template:

```markdown
---
name: <sub-agent-name>
description: <one-line description of role>
tools: [ "read_file", "grep_search", "run_shell_command" ]
---

# <Sub-Agent Name>

## Primary responsibilities
1. ...
2. ...
```

### Case 1 — List sub-agents

```sh
echo "=== Common sub-agents (~/.ai-agents/) ==="
ls ~/.ai-agents/ 2>/dev/null || echo "(none)"

for a in .claude .gemini .codex; do
    echo "=== ${a}-only (~/${a}/agents/) ==="
    ls ~/${a}/agents/ 2>/dev/null || echo "(none)"
done
```

Report the result as a table: sub-agent name, scope (common / agent-specific), description from frontmatter.

### Case 2 — Add common sub-agent (all agents)

```sh
SOURCE_DIR=$(chezmoi source-path)

# Create the sub-agent file
cat > "${SOURCE_DIR}/dot_ai-agents/<name>.md" << 'EOF'
---
name: <name>
description: <description>
tools: [ "read_file", "grep_search", "run_shell_command" ]
---

# <name>
EOF

chezmoi apply   # run_always_sync-agents.sh distributes to all agents automatically
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: add <name> sub-agent"
git push
```

### Case 3 — Add agent-specific sub-agent

Replace `<agent>` with `claude`, `gemini`, or `codex`.

```sh
SOURCE_DIR=$(chezmoi source-path)
mkdir -p "${SOURCE_DIR}/dot_<agent>/agents"

# Create the sub-agent file
cat > "${SOURCE_DIR}/dot_<agent>/agents/<name>.md" << 'EOF'
---
name: <name>
description: <description>
tools: [ "read_file", "grep_search", "run_shell_command" ]
---

# <name>
EOF

chezmoi apply
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: add <name> sub-agent to <agent>"
git push
```

### Case 4 — Promote: agent-specific → common

Moves a sub-agent from one agent's directory to the common hub so all agents receive it.

```sh
SOURCE_DIR=$(chezmoi source-path)

mv "${SOURCE_DIR}/dot_<agent>/agents/<name>.md" "${SOURCE_DIR}/dot_ai-agents/"

chezmoi apply
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: promote <name> to common"
git push
```

### Case 5 — Demote: common → agent-specific

Moves a sub-agent from the common hub to a single agent's directory.

```sh
SOURCE_DIR=$(chezmoi source-path)
mkdir -p "${SOURCE_DIR}/dot_<agent>/agents"

mv "${SOURCE_DIR}/dot_ai-agents/<name>.md" "${SOURCE_DIR}/dot_<agent>/agents/"

chezmoi apply
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: demote <name> to <agent>-only"
git push
```

### Case 6 — Remove sub-agent

```sh
SOURCE_DIR=$(chezmoi source-path)

# Common sub-agent
rm "${SOURCE_DIR}/dot_ai-agents/<name>.md"

# Or agent-specific
rm "${SOURCE_DIR}/dot_<agent>/agents/<name>.md"

chezmoi apply
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: remove <name> sub-agent"
git push
```

## Auto-Update Scheduler

Manages the login-time auto-sync scheduler. Use the appropriate sub-section based on the user's request.

### Check status

Trigger: "스케줄러 상태 확인", "check scheduler", "is auto-sync enabled?"

```sh
# Windows
if schtasks /Query /TN "chezmoi-auto-update" &>/dev/null 2>&1; then
  schtasks /Query /TN "chezmoi-auto-update" /FO LIST
else
  echo "Scheduler not registered."
fi

# Linux/macOS
if crontab -l 2>/dev/null | grep -q 'chezmoi update'; then
  crontab -l | grep 'chezmoi update'
else
  echo "No crontab entry found for chezmoi update."
fi
```

Report back to the user whether the scheduler is active and show its current settings.

### Register (first time)

Trigger: "스케줄러 등록해줘", "set up auto-sync", first-time integration step

```sh
SOURCE_DIR=$(chezmoi source-path)

if [ ! -f "${SOURCE_DIR}/run_once_setup-auto-update.sh" ]; then
  echo "Scheduler script not found. Run first-time integration first."
  exit 1
fi

sh "${SOURCE_DIR}/run_once_setup-auto-update.sh"
```

This registers:
- **Windows**: Task Scheduler task `chezmoi-auto-update` at login
- **Linux/macOS**: crontab `@reboot` entry

### Force re-register

Trigger: "스케줄러 재등록", "re-register scheduler", "scheduler is broken"

`run_once_` scripts are tracked by chezmoi and normally run only once. To force re-registration, run the script directly:

```sh
SOURCE_DIR=$(chezmoi source-path)
sh "${SOURCE_DIR}/run_once_setup-auto-update.sh"
```

This always re-registers regardless of chezmoi's run history.

### Remove

Trigger: "자동 동기화 끄기", "disable auto-sync", "remove scheduler"

```sh
# Windows
schtasks /Delete /TN "chezmoi-auto-update" /F
echo "Scheduler removed."

# Linux/macOS
( crontab -l 2>/dev/null | grep -v 'chezmoi update' ) | crontab -
echo "crontab entry removed."
```

After removal, `chezmoi update` will no longer run automatically at login.

## Important Notes
- Template files (`.tmpl`) are rendered automatically during `chezmoi apply`.
- Secrets or API keys MUST NEVER be committed to Git. Store them in `~/.config/chezmoi/chezmoi.toml` under `[data]`.
- Warning messages like "config file template has changed" during `chezmoi diff` are generally harmless.
- Do NOT track temporary files, logs, or cache directories (e.g., `~/.claude/cache/`) with chezmoi.
