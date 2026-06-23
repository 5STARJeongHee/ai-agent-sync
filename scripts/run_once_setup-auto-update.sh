#!/bin/sh
# 로그인 시 chezmoi update를 자동 실행하는 스케줄 등록
# chezmoi apply 시 머신당 한 번만 실행 — run_once_ prefix가 이를 보장한다
# Windows: PowerShell Register-ScheduledTask | Linux/macOS: crontab(@reboot)

set -e

if command -v powershell.exe >/dev/null 2>&1; then
    # Windows (Git Bash 환경) — chezmoi 실행 파일 경로 탐색
    CHEZMOI_PATH=$(command -v chezmoi 2>/dev/null || true)

    if [ -z "${CHEZMOI_PATH}" ] && [ -n "${USERNAME}" ]; then
        WINGET_PATH="/c/Users/${USERNAME}/AppData/Local/Microsoft/WinGet/Links/chezmoi.exe"
        [ -f "${WINGET_PATH}" ] && CHEZMOI_PATH="${WINGET_PATH}"
    fi

    if [ -z "${CHEZMOI_PATH}" ]; then
        echo "chezmoi executable not found." >&2
        exit 1
    fi

    # Git Bash 경로 → Windows 경로 변환
    if command -v cygpath >/dev/null 2>&1; then
        WIN_PATH=$(cygpath -w "${CHEZMOI_PATH}")
    else
        WIN_PATH=$(echo "${CHEZMOI_PATH}" | sed 's|^/\([a-zA-Z]\)/|\1:\\|; s|/|\\|g')
    fi

    powershell.exe -NoProfile -NonInteractive -Command "
        \$action  = New-ScheduledTaskAction -Execute '${WIN_PATH}' -Argument 'update'
        \$trigger  = New-ScheduledTaskTrigger -AtLogOn -User \$env:USERNAME
        \$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -StartWhenAvailable -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName 'chezmoi-auto-update' -Action \$action -Trigger \$trigger -Settings \$settings -Force | Out-Null
        Write-Host 'Scheduled: chezmoi update will run at every login (Windows Task Scheduler)'
    "

elif command -v crontab >/dev/null 2>&1; then
    # Linux / macOS
    LOG="${HOME}/.local/share/chezmoi-update.log"
    mkdir -p "$(dirname "${LOG}")"
    CRON_LINE="@reboot chezmoi update >> ${LOG} 2>&1"
    ( crontab -l 2>/dev/null | grep -v 'chezmoi update'; echo "${CRON_LINE}" ) | crontab -
    echo "Scheduled: chezmoi update will run at every reboot via crontab (log: ${LOG})"

else
    echo "No scheduler found (requires powershell.exe or crontab)." >&2
    exit 1
fi
