#!/bin/bash
# KWin Monitor - Continuous monitoring with notifications

# Configuration
CPU_THRESHOLD=20.0
CHECK_INTERVAL=60
NTFY_TOPIC="kwin-alerts"
NTFY_URL="https://alerts-24858a9c.a1a1.bid"

send_notification() {
    local title="$1"
    local message="$2"
    
    # Send NTFY notification
    curl -s -H "Title: $title" \
         -H "Priority: high" \
         -d "$message" \
         "$NTFY_URL/$NTFY_TOPIC" > /dev/null 2>&1 &
    
    # Also show desktop notification
    notify-send -u critical "$title" "$message"
    
    echo "[$(date)] ALERT: $title - $message" >> /tmp/kwin_monitor.log
}

check_kwin_health() {
    local cpu_usage=$(ps aux | grep "kwin_x11" | grep -v grep | awk '{print $3}')
    local xcb_errors=$(journalctl --since "1 minute ago" 2>/dev/null | grep "kwin_x11.*XCB error" | wc -l)
    local thread_count=$(ps -L -p $(pgrep kwin_x11) 2>/dev/null | wc -l)
    
    if ! pgrep kwin_x11 > /dev/null; then
        send_notification "❌ KWin Crashed" "kwin_x11 process is not running."
        return 1
    fi
    
    if [ ! -z "$cpu_usage" ] && (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        send_notification "⚠️ KWin High CPU" "kwin_x11 using ${cpu_usage}% CPU"
    fi
    
    if [ "$xcb_errors" -gt 0 ]; then
        send_notification "⚠️ KWin XCB Errors" "Detected $xcb_errors XCB errors"
    fi
    
    if [ "$thread_count" -gt 100 ]; then
        send_notification "⚠️ KWin High Thread Count" "kwin_x11 has $thread_count threads"
    fi
    
    echo "[$(date)] Checked: CPU=${cpu_usage}% XCB_errors=${xcb_errors} Threads=${thread_count}" >> /tmp/kwin_monitor.log
}

while true; do
    check_kwin_health
    sleep $CHECK_INTERVAL
done
