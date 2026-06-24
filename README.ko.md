# AI Agent Sync Plugin

AI 에이전트 환경(Claude, Gemini, Codex)을 여러 머신에서 `chezmoi`와 `git`으로 동기화하는 통합 플러그인.

## 이게 뭔가요?

AI 에이전트별로 스킬·서브에이전트·플러그인 설정을 여러 머신에서 일관되게 관리하기 어렵습니다. 이 플러그인은 에이전트가 `chezmoi`를 통해 자신의 환경을 직접 관리하는 방법을 가르칩니다.

## 제공 스킬

| 스킬 | 설명 |
|------|------|
| `sync-dotfiles` | dotfiles와 에이전트 설정을 원격 git 저장소와 동기화 |
| `manage-skills` | 스킬 추가·수정·제거·승격·강등 (공통 ↔ 에이전트 전용) |
| `list-skills` | 현재 로드된 스킬 목록 조회 |
| `manage-agents` | 서브에이전트 추가·수정·제거·승격·강등 |
| `list-agents` | 에이전트별 서브에이전트 인벤토리 조회 |
| `manage-plugins` | 에이전트별 플러그인/MCP 서버 추가·수정·제거 |
| `list-plugins` | 에이전트별 플러그인 목록 조회 |

## 설치

상세 설치 방법은 [INSTALL.ko.md](INSTALL.ko.md)를 참고하세요.

## 동작 원리

이 플러그인의 모든 변경은 **chezmoi 소스 디렉토리(관리 영역)** 에서만 이루어집니다.
홈 디렉토리의 에이전트 폴더를 직접 수정하면 `chezmoi apply` 시 덮어씌워지므로, 스킬·에이전트·플러그인을 추가·수정·삭제할 때는 항상 소스 디렉토리를 대상으로 합니다.

```
[관리 영역 — chezmoi 소스]              [실제 에이전트 폴더 — 직접 수정 금지]

dot_ai-skills/        →  chezmoi apply  →  ~/.ai-skills/
dot_ai-agents/        →  chezmoi apply  →  ~/.ai-agents/
dot_claude/skills/    →  chezmoi apply  →  ~/.claude/skills/
dot_claude/agents/    →  chezmoi apply  →  ~/.claude/agents/
dot_gemini/skills/    →  chezmoi apply  →  ~/.gemini/skills/
dot_gemini/agents/    →  chezmoi apply  →  ~/.gemini/agents/
dot_codex/skills/     →  chezmoi apply  →  ~/.codex/skills/
dot_codex/agents/     →  chezmoi apply  →  ~/.codex/agents/
        ↓
      git push → 원격 저장소 → 다른 머신에서 pull
```

스킬·에이전트·플러그인을 변경하면 에이전트가 `chezmoi apply` → `git push`까지 자동으로 처리합니다.

## 에이전트별 플러그인 구조

| 에이전트 | 시스템 | 설정 위치 |
|---------|--------|----------|
| Claude Code | 마켓플레이스 (`enabledPlugins`) | `~/.claude/settings.json` |
| Codex | 마켓플레이스 (`[plugins.*]`) | `~/.codex/config.toml` |
| Gemini CLI | Skills 디렉토리 자동 스캔 | `~/.gemini/skills/` |

## 사용 예시

```
/sync-dotfiles                       → chezmoi 초기화 및 dotfiles 저장소 연결
"설정 동기화해줘"                    → 원격 변경사항 pull 후 모든 에이전트에 배포
"스킬 목록 보여줘"                   → 에이전트별 스킬 인벤토리 조회
"플러그인 목록 보여줘"               → 에이전트별 플러그인/MCP 서버 조회
"xxx 스킬 공통으로 승격해줘"         → ~/.ai-skills/로 이동하여 전 에이전트 배포
"ecc 플러그인 추가해줘"              → Claude Code에 ecc 마켓플레이스 플러그인 등록
"xxx 스킬 수정해줘"                  → chezmoi 소스에서 스킬 내용 수정
"cursor를 sync 대상에 추가해줘"      → 새 에이전트를 sync 스크립트에 등록
```

## 디렉토리 구조

```
ai-agent-sync/
├── plugin.json          — 플러그인 메타데이터
├── INSTALL.md           — 상세 설치 가이드 (영문)
├── INSTALL.ko.md        — 상세 설치 가이드 (한국어)
├── PLUGIN-REGISTRY.md   — 등록된 플러그인 레지스트리
├── scripts/
│   ├── run_always_sync-skills.sh    — chezmoi apply 시 공통 스킬 자동 배포
│   └── run_always_sync-agents.sh   — chezmoi apply 시 공통 서브에이전트 자동 배포
└── skills/
    ├── sync-dotfiles/   — dotfiles 동기화, 초기 설정, 스케줄러 관리
    ├── manage-skills/   — 스킬 관리 (추가·수정·제거·승격·강등)
    ├── list-skills/     — 스킬 목록 조회
    ├── manage-agents/   — 서브에이전트 관리 (추가·수정·제거·승격·강등)
    ├── list-agents/     — 서브에이전트 목록 조회
    ├── manage-plugins/  — 플러그인/MCP 서버 관리 (추가·수정·제거)
    └── list-plugins/    — 플러그인 목록 조회
```

## 라이선스

MIT — [LICENSE](LICENSE) 참고.
