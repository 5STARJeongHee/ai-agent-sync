#!/usr/bin/env bash
# AI Agent Sync 초기 설치 스크립트 — chezmoi 설치 및 dotfiles 저장소 연결
set -euo pipefail

INSTALL_DIR="$HOME/bin"

echo "======================================"
echo " AI Agent Sync Setup"
echo "======================================"

# --- 1. chezmoi 설치 확인 ---
if ! command -v chezmoi &>/dev/null; then
    echo "chezmoi not found. Installing to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"

    case "$(uname -s)" in
        Darwin*)
            if command -v brew &>/dev/null; then
                brew install chezmoi
            else
                sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$INSTALL_DIR"
            fi
            ;;
        Linux*)
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$INSTALL_DIR"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Git Bash on Windows: get.chezmoi.io 스크립트가 Windows 바이너리를 다운로드함
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$INSTALL_DIR"
            ;;
        *)
            echo "Unsupported shell environment."
            echo "Please install chezmoi manually: https://www.chezmoi.io/install/"
            echo "  Windows (PowerShell): winget install twpayne.chezmoi"
            exit 1
            ;;
    esac

    export PATH="$INSTALL_DIR:$PATH"

    if ! command -v chezmoi &>/dev/null; then
        echo "Installation failed. Add $INSTALL_DIR to your PATH and retry."
        echo "  Windows alternative: winget install twpayne.chezmoi"
        exit 1
    fi
    echo "chezmoi installed: $(chezmoi --version)"
else
    echo "chezmoi already installed: $(chezmoi --version)"
fi

# --- 2. 이미 초기화된 경우 건너뜀 ---
if chezmoi source-path &>/dev/null 2>&1; then
    echo ""
    echo "chezmoi is already initialized at: $(chezmoi source-path)"
    echo "Run 'chezmoi update' to pull the latest changes."
    exit 0
fi

# --- 3. Git 저장소 URL 입력 및 초기화 ---
echo ""
echo "Enter your Git repository URL for dotfiles/agent settings."
echo "  HTTPS: https://github.com/username/agent_settings.git"
echo "  SSH:   git@github.com:username/agent_settings.git"
echo ""
read -rp "Repository URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "Repository URL cannot be empty."
    exit 1
fi

chezmoi init --apply "$REPO_URL"

echo ""
echo "======================================"
echo " Setup Complete!"
echo "======================================"
echo "Ask your AI agent to 'sync settings' to pull updates."
