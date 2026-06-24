# 설치 가이드

각 에이전트의 플러그인 시스템으로 설치한 뒤, `/sync-dotfiles`를 실행해 chezmoi 초기 설정을 완료합니다.

---

## 목차

- [Claude Code](#claude-code)
- [Gemini CLI / Antigravity](#gemini-cli--antigravity)
- [Codex](#codex)
- [초기 설정](#초기-설정)
- [새 에이전트 추가](#새-에이전트-추가)
- [사용 가능한 기능 목록](#사용-가능한-기능-목록)

---

## Claude Code

### 1. 마켓플레이스 추가

```
/plugin marketplace add https://github.com/5STARJeongHee/ai-agent-sync.git
```

### 2. 플러그인 설치

```
/plugin install ai-agent-sync@ai-agent-sync
```

`enabledPlugins` 설정은 초기 설정 시 `/sync-dotfiles`가 자동으로 처리합니다.

<details>
<summary>수동 설치</summary>

`~/.claude/settings.json`에 아래 내용을 추가합니다.

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

Gemini CLI는 Skills 디렉토리를 자동으로 스캔합니다. 클론만 하면 설치가 완료됩니다.

```sh
mkdir -p ~/.gemini/skills
git clone https://github.com/5STARJeongHee/ai-agent-sync.git \
  ~/.gemini/skills/ai-agent-sync
```

`~/.gemini/skills/` 경로를 자동 인식하므로 별도 설정이 필요 없습니다.

---

## Codex

### 1. 마켓플레이스 추가

```sh
codex plugin marketplace add 5STARJeongHee/ai-agent-sync
```

### 2. 플러그인 설치

```sh
codex plugin install ai-agent-sync@ai-agent-sync
```

Codex는 플러그인을 `~/.codex/plugins/cache/<marketplace>/<plugin>/<version>` 구조로 설치하고, 활성화 설정은 `config.toml`에 기록합니다.

```toml
[plugins."ai-agent-sync@ai-agent-sync"]
enabled = true
```

<details>
<summary>수동 설치</summary>

```sh
git clone https://github.com/5STARJeongHee/ai-agent-sync.git \
  ~/.codex/plugins/ai-agent-sync
```

`~/.codex/config.toml`에 아래 내용을 추가합니다.

```toml
[marketplaces.ai-agent-sync]
source = "github.com/5STARJeongHee/ai-agent-sync"

[plugins."ai-agent-sync@ai-agent-sync"]
enabled = true
```

</details>

---

## 초기 설정

설치 후 에이전트에서 아래 명령어를 실행하세요.

```
/sync-dotfiles
```

`sync-dotfiles` 스킬이 자동으로 아래 과정을 처리합니다.

1. `chezmoi` 설치 여부 확인 및 설치
2. dotfiles 저장소 초기화 또는 기존 저장소 연결
3. 공통 스킬·서브에이전트 디렉토리 구성
4. Claude `settings.json`의 `enabledPlugins` 확인 및 자동 적용
5. 로그인 시 자동 동기화 스케줄러 등록

---

## 새 에이전트 추가

sync 스크립트는 기본적으로 `.claude`, `.gemini`, `.codex`에 공통 스킬·서브에이전트를 배포합니다. 새 에이전트를 추가하려면 에이전트에게 아래와 같이 요청하세요.

> "`.cursor`를 sync 대상에 추가해줘."

`sync-dotfiles` 스킬이 두 sync 스크립트의 `AGENT_DIRS`를 수정하고 `chezmoi apply`까지 자동으로 처리합니다.

---

## 사용 가능한 기능 목록

설치 완료 후 자연어로 요청하세요.

| 기능 | 예시 |
|------|------|
| 스킬 목록 조회 | "스킬 목록 보여줘" |
| 스킬 추가 | "새 스킬 만들어줘" |
| 스킬 수정 | "xxx 스킬 수정해줘" |
| 스킬 승격 | "xxx 스킬을 공통으로 올려줘" |
| 스킬 강등 | "xxx 스킬을 Claude 전용으로 내려줘" |
| 스킬 삭제 | "xxx 스킬 삭제해줘" |
| 서브에이전트 목록 조회 | "에이전트 목록 보여줘" |
| 서브에이전트 추가 | "새 에이전트 만들어줘" |
| 서브에이전트 수정 | "xxx 에이전트 수정해줘" |
| 서브에이전트 승격/강등 | "xxx 에이전트를 공통으로 올려줘" |
| 플러그인 목록 조회 | "플러그인 목록 보여줘" |
| 플러그인 추가 | "ecc 플러그인 추가해줘" |
| 플러그인 수정 | "xxx 플러그인 설정 수정해줘" |
| 플러그인 제거 | "xxx 플러그인 제거해줘" |
| 설정 동기화 | "설정 동기화해줘" |
| 새 에이전트 sync 등록 | "cursor를 sync 대상에 추가해줘" |
