---
name: list-skills
description: |
  관리되는 모든 에이전트(Claude, Gemini, Codex)의 스킬 목록을 조회하는 스킬.
  "스킬 목록 보여줘", "어떤 스킬 있어?", "공통 스킬 알려줘", "에이전트별 스킬 뭐 있어?" 등의
  요청을 받으면 이 스킬을 사용한다.
---

# list-skills

모든 에이전트의 스킬 인벤토리를 조회하여 정리된 표 형태로 출력한다.

## 실행 절차

### Step 1 — 공통 스킬 목록 수집

```sh
ls "${HOME}/.ai-skills/"
```

각 디렉토리에서 SKILL.md의 `description` 필드를 읽어 한 줄 설명을 추출한다.

```sh
# SKILL.md 의 description 첫 줄 추출 예시
head -5 "${HOME}/.ai-skills/<skill-name>/SKILL.md" | grep -A2 "^description:" | tail -1 | sed 's/^[[:space:]]*//'
```

### Step 2 — 에이전트별 고유 스킬 목록 수집

각 에이전트 skills 디렉토리를 확인한다.

```sh
ls "${HOME}/.claude/skills/"   2>/dev/null
ls "${HOME}/.gemini/skills/"   2>/dev/null
ls "${HOME}/.codex/skills/"    2>/dev/null
```

공통 스킬(`.ai-skills/`에 있는 것)과 동명인 항목은 에이전트 고유 목록에서 제외한다.

### Step 3 — 결과 출력

아래 형식으로 출력한다.

---

## 공통 스킬 (`~/.ai-skills/`)

모든 에이전트(Claude, Gemini, Codex)에서 사용 가능한 스킬.

| 스킬 | 설명 |
|------|------|
| save-to-notion | 대화 내용을 Notion DB에 구조화하여 저장 |
| list-skills | 모든 에이전트 스킬 목록 조회 (현재 스킬) |
| manage-skills | 스킬 추가/이동/제거/승격 자동화 |
| sync-dotfiles | chezmoi apply 및 git push로 설정 동기화 |
| manage-plugins | 에이전트별 플러그인 추가/제거 관리 |

## Claude 고유 스킬 (`~/.claude/skills/`)

| 스킬 | 설명 |
|------|------|
| investment-advisor | 투자 조언 및 분석 |

## Gemini 고유 스킬 (`~/.gemini/skills/`)

| 스킬 | 설명 |
|------|------|
| code-review | 보안/성능/컨벤션 기반 코드 리뷰 |
| git-commit-helper | Jira 연동 Git 커밋 메시지 작성 |

## Codex 고유 스킬 (`~/.codex/skills/`)

현재 없음.

---

## 주의사항

- 실제 파일시스템을 읽어서 출력한다. 위 내용은 예시 형식이다.
- 디렉토리가 없는 에이전트는 "설치되지 않음"으로 표시한다.
- 새 스킬을 추가하려면 `manage-skills` 스킬을 사용한다.
