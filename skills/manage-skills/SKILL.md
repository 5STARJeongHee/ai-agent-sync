---
name: manage-skills
description: |
  스킬을 추가, 수정, 이동, 제거하고 chezmoi apply + git push 까지 자동화하는 스킬.
  "새 스킬 만들어줘", "스킬을 공통으로 올려줘", "이 스킬을 다른 에이전트에도 줘",
  "스킬 삭제해줘" 등의 요청을 받으면 이 스킬을 사용한다.
---

# manage-skills

스킬 생성/수정/이동/제거를 chezmoi 소스 디렉토리에서 직접 수행하고 적용까지 완료한다.

## 핵심 원칙

- **홈 디렉토리(`~/.claude/skills/` 등)를 직접 수정하지 않는다.** chezmoi apply 시 덮어씌워진다.
- 모든 변경은 **chezmoi 소스 디렉토리**에서 수행한다.
- 소스 경로는 항상 `chezmoi source-path` 명령으로 확인한다. 절대 경로를 하드코딩하지 않는다.
- 변경 후 반드시 `chezmoi apply` → git commit → git push 순서로 마무리한다.
- `SKILL-REGISTRY.md`도 항상 최신 상태로 업데이트한다.

## 소스 경로 확인

```sh
SOURCE_DIR=$(chezmoi source-path)
# 예: /home/user/.local/share/chezmoi  또는  ~/agent_settings
```

## 작업별 절차

### A. 신규 공통 스킬 추가

모든 에이전트에서 사용할 스킬을 새로 만든다.

```sh
SOURCE_DIR=$(chezmoi source-path)
SKILL_NAME="<스킬명>"

mkdir -p "${SOURCE_DIR}/dot_ai-skills/${SKILL_NAME}"
# SKILL.md 작성 (frontmatter: name, description 필수)
```

SKILL.md 최소 구조:
```markdown
---
name: <스킬명>
description: |
  한 줄 설명. 에이전트가 언제 이 스킬을 쓸지 적는다.
---

# <스킬명>

스킬 설명 및 실행 절차.
```

### B. 신규 에이전트 전용 스킬 추가

특정 에이전트에만 스킬을 추가할 때.

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT="<claude|gemini|codex>"
SKILL_NAME="<스킬명>"

mkdir -p "${SOURCE_DIR}/dot_${AGENT}/skills/${SKILL_NAME}"
# SKILL.md 작성
```

### C. 에이전트 전용 스킬 → 공통으로 승격

기존 에이전트 전용 스킬을 모든 에이전트가 쓸 수 있게 공통으로 올린다.

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT="<claude|gemini|codex>"
SKILL_NAME="<스킬명>"

# 공통으로 이동
mv "${SOURCE_DIR}/dot_${AGENT}/skills/${SKILL_NAME}" \
   "${SOURCE_DIR}/dot_ai-skills/${SKILL_NAME}"

# 원래 에이전트 디렉토리에서 제거됨 (다른 에이전트에는 run_always_sync-skills.sh 가 배포)
```

### D. 공통 스킬 → 특정 에이전트 전용으로 이동

공통 스킬을 특정 에이전트에서만 쓰도록 내린다.

```sh
SOURCE_DIR=$(chezmoi source-path)
AGENT="<claude|gemini|codex>"
SKILL_NAME="<스킬명>"

mkdir -p "${SOURCE_DIR}/dot_${AGENT}/skills"
mv "${SOURCE_DIR}/dot_ai-skills/${SKILL_NAME}" \
   "${SOURCE_DIR}/dot_${AGENT}/skills/${SKILL_NAME}"
```

### E. 에이전트 A → 에이전트 B로 복사

스킬을 원본 에이전트에 남기면서 다른 에이전트에도 추가한다.

```sh
SOURCE_DIR=$(chezmoi source-path)
SRC_AGENT="<claude|gemini|codex>"
DST_AGENT="<claude|gemini|codex>"
SKILL_NAME="<스킬명>"

mkdir -p "${SOURCE_DIR}/dot_${DST_AGENT}/skills"
cp -rp "${SOURCE_DIR}/dot_${SRC_AGENT}/skills/${SKILL_NAME}" \
       "${SOURCE_DIR}/dot_${DST_AGENT}/skills/${SKILL_NAME}"
```

### F. 스킬 제거

```sh
SOURCE_DIR=$(chezmoi source-path)
SKILL_NAME="<스킬명>"

# 공통 스킬 제거
rm -rf "${SOURCE_DIR}/dot_ai-skills/${SKILL_NAME}"

# 에이전트 전용 스킬 제거
# rm -rf "${SOURCE_DIR}/dot_<agent>/skills/${SKILL_NAME}"
```

> **주의:** chezmoi는 소스에서 제거해도 홈 디렉토리의 파일을 자동 삭제하지 않는다.
> 홈에서도 제거하려면 `chezmoi apply` 후 수동으로 삭제하거나, 디렉토리에 `exact_` 접두어 사용을 고려한다.

### G. 기존 스킬 내용 수정

```sh
SOURCE_DIR=$(chezmoi source-path)
# dot_ai-skills/<스킬명>/SKILL.md 또는 dot_<agent>/skills/<스킬명>/SKILL.md 를 직접 편집
```

## 변경 후 공통 마무리 절차

모든 작업(A~G) 완료 후 반드시 실행.

```sh
SOURCE_DIR=$(chezmoi source-path)

# 1. 변경사항 확인
chezmoi diff

# 2. 홈 디렉토리에 적용 (공통 스킬 sync 포함)
chezmoi apply

# 3. git commit & push
cd "${SOURCE_DIR}"
git add -A
git commit -m "skill: <변경 내용 한 줄 설명>"
git push
```

## SKILL-REGISTRY.md 업데이트

작업 완료 후 `${SOURCE_DIR}/SKILL-REGISTRY.md`의 스킬 표를 최신 상태로 유지한다.

```sh
# 현재 공통 스킬 목록 확인
ls "${SOURCE_DIR}/dot_ai-skills/"

# 에이전트별 고유 스킬 확인
ls "${SOURCE_DIR}/dot_claude/skills/"
ls "${SOURCE_DIR}/dot_gemini/skills/"
ls "${SOURCE_DIR}/dot_codex/skills/"
```
