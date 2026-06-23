---
name: manage-plugins
description: |
  에이전트별 플러그인(Claude ecc, Codex marketplace, Gemini MCP)을 추가/제거하는 스킬.
  "플러그인 추가해줘", "MCP 서버 등록해줘", "ecc 플러그인 켜줘", "Codex 플러그인 설치해줘",
  "플러그인 목록 보여줘" 등의 요청을 받으면 이 스킬을 사용한다.
---

# manage-plugins

에이전트마다 플러그인 구조가 완전히 다르다. 에이전트를 먼저 확인하고 해당 절차를 따른다.

## 에이전트별 플러그인 구조 비교

| 에이전트 | 시스템 | 설정 파일 | 특징 |
|---------|--------|-----------|------|
| Claude Code | 마켓플레이스 기반 | `dot_claude/settings.json.tmpl` | `enabledPlugins`, `extraKnownMarketplaces` |
| Codex | OpenAI 마켓플레이스 | `dot_codex/config.toml` | `[plugins."name@marketplace"]` TOML |
| Gemini CLI | MCP 프로토콜 | `dot_gemini/settings.json.tmpl` | `mcpServers` JSON 설정 |

---

## Claude Code 플러그인 관리

설정 위치: chezmoi 소스의 `dot_claude/settings.json.tmpl`

### 플러그인 활성화

```json
"enabledPlugins": {
  "ecc@ecc": true,
  "<plugin-name>@<marketplace>": true
}
```

### 마켓플레이스 추가

```json
"extraKnownMarketplaces": {
  "<marketplace-id>": {
    "source": {
      "source": "git",
      "url": "https://github.com/<owner>/<repo>.git"
    }
  }
}
```

### 현재 설치된 플러그인 확인

```sh
ls "${HOME}/.claude/plugins/cache/"
cat "${HOME}/.claude/plugins/installed_plugins.json"
```

### 플러그인 비활성화

`enabledPlugins`에서 해당 항목을 `false`로 변경하거나 제거한다.

---

## Codex 플러그인 관리

설정 위치: chezmoi 소스의 `dot_codex/config.toml`

### 플러그인 추가

```toml
[plugins."<plugin-name>@<marketplace-url>"]
enabled = true
```

예시:
```toml
[plugins."browser-use@openai-bundled"]
enabled = true
```

### 플러그인 제거

해당 `[plugins.*]` 섹션을 삭제한다.

### 주의사항

- `[marketplaces.*]`와 `[projects.*]` 섹션은 머신별로 다르므로 chezmoi로 관리하지 않는다.
- Codex가 자동으로 추가하는 설정이므로 로컬에서 직접 관리한다.

---

## Gemini CLI 플러그인(MCP 서버) 관리

설정 위치: chezmoi 소스의 `dot_gemini/settings.json.tmpl`

Gemini는 전통적 플러그인 시스템 없이 MCP 서버로 기능을 확장한다.

### MCP 서버 추가 (시크릿 없는 경우)

```json
"mcpServers": {
  "<server-name>": {
    "command": "npx",
    "args": ["-y", "@<scope>/<package>"],
    "env": {}
  }
}
```

### MCP 서버 추가 (API 토큰 필요한 경우)

chezmoi 템플릿 변수를 사용한다. 토큰은 `~/.config/chezmoi/chezmoi.toml`의 `[data]`에 저장.

1. `~/.config/chezmoi/chezmoi.toml`에 토큰 추가:

```toml
[data]
  newServiceToken = "your-token-here"
```

2. `.chezmoi.yaml.tmpl`에 `promptStringOnce` 추가:

```yaml
{{- $newToken := promptStringOnce . "newServiceToken" "New Service API Token" -}}
data:
  newServiceToken: {{ $newToken | quote }}
```

3. `dot_gemini/settings.json.tmpl`에서 변수 참조:

```json
"env": {
  "API_TOKEN": {{ .newServiceToken | quote }}
}
```

### MCP 서버 제거

`mcpServers` 객체에서 해당 키를 제거한다.

---

## 변경 후 공통 마무리

```sh
SOURCE_DIR=$(chezmoi source-path)

chezmoi diff
chezmoi apply

cd "${SOURCE_DIR}"
git add -A
git commit -m "plugin: <변경 내용>"
git push
```

## PLUGIN-REGISTRY.md 업데이트

`${SOURCE_DIR}/PLUGIN-REGISTRY.md`의 플러그인 표를 최신 상태로 유지한다.
