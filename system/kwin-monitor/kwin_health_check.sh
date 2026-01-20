#!/bin/bash
# KWin Health Check - Quick manual check

LOG_FILE="/tmp/kwin_health.log"

# Simple check without external dependencies
check_kwin() {
    echo "=== KWin Health Check $(date) ===" >> "$LOG_FILE"
    
    # Check if kwin_x11 is running
    if ! pgrep kwin_x11 > /dev/null; then
        echo "❌ CRITICAL: kwin_x11 is not running!" | tee -a "$LOG_FILE"
        notify-send -u critical "KWin Crashed" "kwin_x11 process terminated"
        return 1
    fi
    
    # Check CPU usage
    CPU_USAGE=$(ps -p $(pgrep kwin_x11) -o %cpu --no-headers 2>/dev/null)
    if [ ! -z "$CPU_USAGE" ] && [ $(echo "$CPU_USAGE > 15" | bc -l 2>/dev/null || echo 0) -eq 1 ]; then
        echo "⚠️ WARNING: kwin_x11 CPU usage: ${CPU_USAGE}%" | tee -a "$LOG_FILE"
        notify-send -u normal "KWin High CPU" "CPU: ${CPU_USAGE}% - Consider restarting"
    else
        echo "✅ Normal: kwin_x11 CPU usage: ${CPU_USAGE:-0}%" >> "$LOG_FILE"
    fi
    
    # Check for recent crashes
    if journalctl --since "5 minutes ago" 2>/dev/null | grep -q "kwin_x11.*crash\|kwin_x11.*XCB error"; then
        echo "⚠️ WARNING: Recent kwin_x11 errors detected" | tee -a "$LOG_FILE"
        notify-send -u low "KWin Issues" "Recent errors detected in logs"
    fi
}

# Run check
check_kwin

echo "Check completed. Log: $LOG_FILE"
