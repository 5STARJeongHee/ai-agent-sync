#!/bin/sh
# 공통 스킬(~/.ai-skills/)을 모든 에이전트 skills/ 디렉토리에 배포
# chezmoi apply 시 자동 실행 — 파일명의 run_always_ prefix가 이를 보장한다

set -e

AI_SKILLS="${HOME}/.ai-skills"
AGENT_DIRS=".claude .gemini .codex"

# 공통 스킬 디렉토리가 없으면 조용히 종료
[ -d "${AI_SKILLS}" ] || exit 0

for agent in ${AGENT_DIRS}; do
    target="${HOME}/${agent}/skills"
    mkdir -p "${target}"

    for skill_dir in "${AI_SKILLS}"/*/; do
        [ -d "${skill_dir}" ] || continue
        name=$(basename "${skill_dir}")
        rm -rf "${target}/${name}"
        cp -rp "${skill_dir%/}" "${target}/"
    done
done

echo "Common skills synced: ${AI_SKILLS} → each agent skills/"
