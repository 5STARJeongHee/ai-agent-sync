---
name: manage-agents
description: |
  서브에이전트(Subagent)를 생성, 수정, 이동, 제거하고 chezmoi apply + git push 까지 자동화하는 스킬.
  "새 에이전트 만들어줘", "이 에이전트를 공통으로 올려줘", "에이전트 삭제해줘" 등의 요청을 받으면 이 스킬을 사용한다.
---

# manage-agents

서브에이전트 생성/수정/이동/제거를 chezmoi 소스 디렉토리에서 직접 수행하고 적용까지 완료한다.

## 핵심 원칙

- **에이전트 디렉토리(~/.gemini/agents/ 등)를 직접 수정하지 않는다.** chezmoi apply 시 덮어씌워진다.
- 모든 변경은 **chezmoi 소스 디렉토리**에서 수행한다.
- 소스 경로는 항상 'chezmoi source-path' 명령으로 확인한다.
- 변경 후 반드시 'chezmoi apply' -> git commit -> git push 순서로 마무리한다.
- 'AGENT-REGISTRY.md'(또는 SKILL-REGISTRY.md)도 항상 최신 상태로 업데이트한다.

## 소스 경로 확인

```sh
SOURCE_DIR=$(chezmoi source-path)
```

## 작업별 절차

### A. 신규 공통 에이전트 추가

모든 에이전트(Claude, Gemini, Codex)에서 사용할 서브에이전트를 새로 만든다.

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT_NAME="<에이전트명>"

# dot_ai-agents/ 폴더에 <에이전트명>.md 파일 생성
# YAML frontmatter 포함 필수 (name, description, tools 등)
```

에이전트 파일(.md) 구조 예시:
```markdown
---
name: <에이전트명>
description: <에이전트 역할 설명>
tools: [ "read_file", "run_shell_command" ] # 허용할 도구 목록
---

# <에이전트명> 시스템 프롬프트

여기에 에이전트의 구체적인 페르소나와 지침을 작성합니다.
```

### B. 신규 특정 에이전트 전용 서브에이전트 추가

특정 메인 에이전트에만 서브에이전트를 추가할 때.

```sh
SOURCE_DIR=$(chezmoi source-path)
MAIN_AGENT="<claude|gemini|codex>"
SUB_AGENT_NAME="<서브에이전트명>"

mkdir -p "${SOURCE_DIR}/dot_${MAIN_AGENT}/agents"
# "${SOURCE_DIR}/dot_${MAIN_AGENT}/agents/${SUB_AGENT_NAME}.md" 생성
```

### C. 에이전트 전용 -> 공통으로 승격

```sh
SOURCE_DIR=$(chezmoi source-path)
MAIN_AGENT="<claude|gemini|codex>"
AGENT_NAME="<에이전트명>"

mv "${SOURCE_DIR}/dot_${MAIN_AGENT}/agents/${AGENT_NAME}.md" \
   "${SOURCE_DIR}/dot_ai-agents/"
```

### D. 공통 -> 특정 에이전트 전용으로 이동

```sh
SOURCE_DIR=$(chezmoi source-path)
MAIN_AGENT="<claude|gemini|codex>"
AGENT_NAME="<에이전트명>"

mkdir -p "${SOURCE_DIR}/dot_${MAIN_AGENT}/agents"
mv "${SOURCE_DIR}/dot_ai-agents/${AGENT_NAME}.md" \
   "${SOURCE_DIR}/dot_${MAIN_AGENT}/agents/"
```

### E. 기존 서브에이전트 수정

수정할 에이전트가 공통인지 전용인지 먼저 확인한다.

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT_NAME="<에이전트명>"

# 위치 확인
ls "${SOURCE_DIR}/dot_ai-agents/${AGENT_NAME}.md" 2>/dev/null
ls "${SOURCE_DIR}/dot_claude/agents/${AGENT_NAME}.md" 2>/dev/null
ls "${SOURCE_DIR}/dot_gemini/agents/${AGENT_NAME}.md" 2>/dev/null
ls "${SOURCE_DIR}/dot_codex/agents/${AGENT_NAME}.md" 2>/dev/null
```

수정 가능한 항목.
- **description (frontmatter)** — 에이전트 역할 설명. 오케스트레이터가 위임 판단에 사용함.
- **tools (frontmatter)** — 허용 도구 목록 추가·제거.
- **시스템 프롬프트 본문** — 페르소나, 지침, 출력 형식 등.
- **name (frontmatter)** — 이름 변경 시 파일명도 함께 변경해야 함.

```sh
# 이름 변경 예시 (공통 에이전트)
mv "${SOURCE_DIR}/dot_ai-agents/${AGENT_NAME}.md" \
   "${SOURCE_DIR}/dot_ai-agents/<새에이전트명>.md"
```

### F. 서브에이전트 제거

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT_NAME="<에이전트명>"

# 공통 제거
rm -f "${SOURCE_DIR}/dot_ai-agents/${AGENT_NAME}.md"

# 특정 에이전트 전용 제거
# rm -f "${SOURCE_DIR}/dot_<main_agent>/agents/${AGENT_NAME}.md"
```

## 변경 후 공통 마무리 절차

모든 작업 완료 후 반드시 실행.

```sh
SOURCE_DIR=$(chezmoi source-path)

# 1. 변경사항 확인
chezmoi diff

# 2. 홈 디렉토리에 적용 (공통 에이전트 sync 포함)
chezmoi apply

# 3. git commit & push
cd "${SOURCE_DIR}"
git add -A
git commit -m "agent: <변경 내용 한 줄 설명>"
git push
```
