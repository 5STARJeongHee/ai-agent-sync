---
name: list-agents
description: |
  모든 에이전트의 서브에이전트 인벤토리를 조회하여 정리된 표 형태로 출력한다.
---

# list-agents

모든 에이전트의 서브에이전트 목록을 조회한다.

## 실행 절차

### Step 1 — 공통 서브에이전트 목록 수집

```sh
ls "${HOME}/.ai-agents/" 2>/dev/null
```

각 `.md` 파일의 frontmatter에서 `name`과 `description` 필드를 추출한다.

### Step 2 — 에이전트별 전용 서브에이전트 수집

각 에이전트 agents 디렉토리를 확인한다.

```sh
ls "${HOME}/.claude/agents/"   2>/dev/null
ls "${HOME}/.gemini/agents/"   2>/dev/null
ls "${HOME}/.codex/agents/"    2>/dev/null
```

공통 에이전트와 동명인 항목은 전용 목록에서 제외한다.

### Step 3 — 결과 출력

아래 형식으로 출력한다.

---

## 공통 서브에이전트 (`~/.ai-agents/`)

모든 에이전트(Claude, Gemini, Codex)에서 사용 가능한 전문가들.

| 에이전트 | 설명 |
|------|------|
| <name> | <description> |

## Claude 전용 서브에이전트 (`~/.claude/agents/`)

| 에이전트 | 설명 |
|------|------|
| ... | ... |

## Gemini 전용 서브에이전트 (`~/.gemini/agents/`)

| 에이전트 | 설명 |
|------|------|
| ... | ... |

---

## 주의사항

- 실제 파일시스템을 읽어서 출력한다.
- 새 에이전트를 추가하거나 관리하려면 `manage-agents` 스킬을 사용한다.
