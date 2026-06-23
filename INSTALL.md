# ai-agent-sync 설치 가이드

Claude, Gemini, Codex 각 에이전트별 설치 방법을 안내합니다.

---

## 공통 전제 조건 — chezmoi 설치 및 초기화

ai-agent-sync의 모든 기능은 chezmoi 기반으로 동작합니다.
**플러그인 설치 전에 반드시 아래를 먼저 확인하세요.**

### chezmoi 설치

```sh
# macOS / Linux / Git Bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin

# Windows (PowerShell)
winget install twpayne.chezmoi
```

### chezmoi dotfiles 초기화

기존 dotfiles 저장소가 있다면:

```sh
chezmoi init --apply https://github.com/<your-username>/<your-dotfiles-repo>.git
```

처음 설정하는 경우 설치 후 Claude에게 **"초기 설정해줘"** 라고 하면 단계별 안내를 받을 수 있습니다.

---

## Claude Code 설치

### 방법 A — 마켓플레이스로 등록 후 설치 (권장)

Claude Code 의 `/plugin` 명령어를 사용합니다.

```
/plugin marketplace add https://github.com/5STARJeongHee/ai-agent-sync.git
/plugin install ai-agent-sync@ai-agent-sync
```

또는 `~/.claude/settings.json` 을 직접 수정합니다.

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

chezmoi 로 settings.json 을 관리하고 있다면 `dot_claude/settings.json.tmpl` 을 수정하세요.

### 방법 B — 스킬만 직접 설치

Vibe Index CLI 사용:

```sh
npx vibeindex add 5STARJeongHee/ai-agent-sync
```

또는 수동 복사:

```sh
git clone https://github.com/5STARJeongHee/ai-agent-sync.git /tmp/ai-agent-sync

# 스킬 복사
cp -r /tmp/ai-agent-sync/skills/* ~/.claude/skills/
```

### 설치 확인

Claude 에서 다음 중 하나를 입력합니다.

```
스킬 목록 보여줘
list skills
```

`list-skills`, `manage-skills`, `sync-dotfiles` 등이 표시되면 정상입니다.

---

## Gemini CLI 설치

Gemini 는 Claude 와 같은 플러그인 마켓플레이스가 없습니다.
스킬 파일을 `~/.gemini/skills/` 에 배포하는 방식으로 설치합니다.

### 방법 A — Vibe Index CLI (권장)

```sh
npx vibeindex add 5STARJeongHee/ai-agent-sync
```

이 명령은 스킬을 Gemini 스킬 디렉토리에 자동으로 배포합니다.

### 방법 B — 수동 설치

```sh
git clone https://github.com/5STARJeongHee/ai-agent-sync.git /tmp/ai-agent-sync

# 스킬 복사
mkdir -p ~/.gemini/skills
cp -r /tmp/ai-agent-sync/skills/* ~/.gemini/skills/
```

### 방법 C — 플러그인 디렉토리로 설치

```sh
mkdir -p ~/.gemini/config/plugins
git clone https://github.com/5STARJeongHee/ai-agent-sync.git \
  ~/.gemini/config/plugins/ai-agent-sync
```

Gemini 재시작 후 스킬이 인식됩니다.

### 설치 확인

Gemini 에서 다음을 입력합니다.

```
스킬 목록 보여줘
```

---

## Codex 설치

### 방법 A — 플러그인 마켓플레이스

Codex 설정 파일 (`~/.codex/config.toml`) 에 추가합니다.

```toml
[plugins."ai-agent-sync@https://github.com/5STARJeongHee/ai-agent-sync.git"]
enabled = true
```

chezmoi 로 관리하고 있다면 `dot_codex/config.toml` 을 수정하세요.

### 방법 B — 수동 스킬 설치

```sh
git clone https://github.com/5STARJeongHee/ai-agent-sync.git /tmp/ai-agent-sync

mkdir -p ~/.codex/skills
cp -r /tmp/ai-agent-sync/skills/* ~/.codex/skills/
```

### 설치 확인

Codex 에서 다음을 입력합니다.

```
list skills
```

---

## 설치 후 초기 설정 (chezmoi 미설정 사용자)

플러그인 설치 후 에이전트에게 다음과 같이 말하면 단계별 안내를 받습니다.

```
초기 설정해줘
```

또는 영어로:

```
Set up for the first time
```

`sync-dotfiles` 스킬이 자동으로 실행되어 다음을 안내합니다.

1. chezmoi 설치 여부 확인
2. dotfiles 저장소 초기화 (`chezmoi init --apply <repo-url>`)
3. 자동 동기화 스크립트 다운로드
4. 로그인 시 자동 업데이트 스케줄러 등록

---

## 지원 기능 요약

설치 완료 후 사용할 수 있는 기능입니다.

| 기능 | 예시 명령 |
|------|-----------|
| 스킬 목록 조회 | "스킬 목록 보여줘" |
| 스킬 추가 | "새 스킬 만들어줘" |
| 스킬 공통으로 승격 | "이 스킬을 공통으로 올려줘" |
| 스킬 특정 에이전트로 강등 | "이 스킬을 Claude 전용으로 내려줘" |
| 스킬 삭제 | "이 스킬 삭제해줘" |
| 서브에이전트 목록 조회 | "에이전트 목록 보여줘" |
| 서브에이전트 추가 | "새 에이전트 만들어줘" |
| 서브에이전트 승격/강등 | "이 에이전트를 공통으로 올려줘" |
| 플러그인 목록 조회 | "플러그인 목록 보여줘" |
| 플러그인 추가 | "플러그인 추가해줘" |
| 설정 동기화 | "설정 동기화해줘" |
| 스케줄러 상태 확인 | "스케줄러 상태 확인해줘" |
| 자동 동기화 설정 | "자동 동기화 설정해줘" |

---

## 에이전트별 플러그인 시스템 비교

| 항목 | Claude Code | Codex | Gemini CLI |
|------|-------------|-------|------------|
| 플러그인 포맷 | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` | 없음 (파일 배포 방식) |
| 마켓플레이스 포맷 | `.claude-plugin/marketplace.json` | 없음 | 없음 |
| 스킬 경로 | `~/.claude/skills/` | `~/.codex/skills/` | `~/.gemini/skills/` |
| 설치 명령 | `/plugin install <name>@<marketplace>` | config.toml 직접 수정 | 수동 복사 또는 CLI |
| 플러그인 확장 방식 | marketplace 등록 | config.toml | MCP 서버 |
