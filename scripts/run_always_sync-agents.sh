#!/bin/sh
# 공통 sub-agent(~/.ai-agents/)를 모든 에이전트 agents/ 디렉토리에 배포
# chezmoi apply 시 자동 실행 — 파일명의 run_always_ prefix가 이를 보장한다

set -e

AI_AGENTS="${HOME}/.ai-agents"
AGENT_DIRS=".claude .gemini .codex"

# 공통 sub-agent 디렉토리가 없으면 조용히 종료
[ -d "${AI_AGENTS}" ] || exit 0
[ "$(ls -A "${AI_AGENTS}" 2>/dev/null)" ] || exit 0

for agent in ${AGENT_DIRS}; do
    target="${HOME}/${agent}/agents"
    mkdir -p "${target}"
    cp -rp "${AI_AGENTS}"/* "${target}/"
done

echo "Common sub-agents synced: ${AI_AGENTS} → each agent agents/"
