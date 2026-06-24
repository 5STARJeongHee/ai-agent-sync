---
name: list-plugins
description: |
  관리되는 모든 에이전트(Claude, Gemini, Codex)의 플러그인 목록을 조회하는 스킬.
  "플러그인 목록 보여줘", "어떤 플러그인 있어?", "에이전트별 플러그인 알려줘",
  "MCP 서버 목록", "Codex 플러그인 뭐 있어?" 등의 요청을 받으면 이 스킬을 사용한다.
---

# list-plugins

에이전트마다 플러그인 시스템이 다르므로 각각의 설정 파일을 읽어 목록을 수집한다.

## 실행 절차

### Step 1 — Claude Code 플러그인 조회

설치된 플러그인:
```sh
cat "${HOME}/.claude/plugins/installed_plugins.json" 2>/dev/null || echo "(파일 없음)"
```

활성화 상태:
```sh
SOURCE_DIR=$(chezmoi source-path)
grep -A 10 '"enabledPlugins"' "${SOURCE_DIR}/dot_claude/settings.json.tmpl" 2>/dev/null \
  || grep -A 10 '"enabledPlugins"' "${HOME}/.claude/settings.json" 2>/dev/null \
  || echo "(enabledPlugins 항목 없음)"
```

### Step 2 — Codex 플러그인 조회

Codex는 플러그인을 `~/.codex/plugins/cache/<marketplace>/<plugin>/<version>` 구조로 캐시한다.
활성화 설정은 `config.toml`에서 확인하고, 실제 설치 목록은 캐시 디렉토리에서 확인한다.

```sh
SOURCE_DIR=$(chezmoi source-path)

# 활성화 설정 확인
echo "=== Codex 활성화 설정 (config.toml) ==="
grep -A 2 '^\[plugins\.' "${SOURCE_DIR}/dot_codex/config.toml" 2>/dev/null \
  || grep -A 2 '^\[plugins\.' "${HOME}/.codex/config.toml" 2>/dev/null \
  || echo "(Codex 플러그인 설정 없음)"

# 실제 설치된 플러그인 캐시 확인
echo ""
echo "=== Codex 설치된 플러그인 캐시 (~/.codex/plugins/cache/) ==="
if [ -d "${HOME}/.codex/plugins/cache" ]; then
  find "${HOME}/.codex/plugins/cache" -mindepth 3 -maxdepth 3 -type d \
    | sed "s|${HOME}/.codex/plugins/cache/||" \
    | awk -F'/' '{print $1 "/" $2 " (v" $3 ")"}'
else
  echo "(캐시 없음)"
fi
```

### Step 3 — Gemini MCP 서버 조회

Gemini는 플러그인 대신 MCP 서버로 기능을 확장한다.

```sh
SOURCE_DIR=$(chezmoi source-path)
grep -A 5 '"mcpServers"' "${SOURCE_DIR}/dot_gemini/settings.json.tmpl" 2>/dev/null \
  || grep -A 5 '"mcpServers"' "${HOME}/.gemini/settings.json" 2>/dev/null \
  || echo "(MCP 서버 없음)"
```

### Step 4 — 결과 출력

아래 형식으로 출력한다.

---

## Claude Code 플러그인 (`~/.claude/settings.json`)

| 플러그인 | 마켓플레이스 | 활성 |
|---------|-------------|------|
| ecc | ecc | ✅ |

## Codex 플러그인 (`~/.codex/config.toml`)

| 플러그인 | 마켓플레이스 | 활성 |
|---------|-------------|------|
| browser-use | openai-bundled | ✅ |

## Gemini MCP 서버 (`~/.gemini/settings.json`)

| 서버명 | 실행 명령 |
|--------|----------|
| notion | npx @modelcontextprotocol/server-notion |

---

## 주의사항

- 실제 파일시스템을 읽어서 출력한다. 위 내용은 예시 형식이다.
- chezmoi가 초기화되지 않은 경우 홈 디렉토리 파일을 직접 읽는다.
- 플러그인을 추가하거나 제거하려면 `manage-plugins` 스킬을 사용한다.
