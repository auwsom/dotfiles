#!/bin/bash
# KWin Cron Monitor - Run every 10 minutes

LOG_FILE="/tmp/kwin_cron_monitor.log"
MAX_LOG_SIZE=1000000

if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
fi

~/kwin_health_check.sh >> "$LOG_FILE" 2>&1

KWIN_PID=$(pgrep kwin_x11)
if [ -z "$KWIN_PID" ]; then
    echo "[CRITICAL] kwin_x11 not running - attempting restart" >> "$LOG_FILE"
    kwin_x11 --replace &
    sleep 5
    if pgrep kwin_x11 > /dev/null; then
        echo "[SUCCESS] kwin_x11 restarted" >> "$LOG_FILE"
    else
        echo "[FAILED] Could not restart kwin_x11" >> "$LOG_FILE"
    fi
fi

echo "---" >> "$LOG_FILE"
