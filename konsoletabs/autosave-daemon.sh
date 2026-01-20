#!/bin/bash
# Auto-save Konsole session every 30 minutes
# This script runs in background and periodically saves sessions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.config/konsole-autosave.log"
INTERVAL=1800  # 30 minutes in seconds

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to save session
save_session() {
    log_message "Starting automatic session save..."
    
    if "$SCRIPT_DIR/save-session-advanced.sh" > /dev/null 2>&1; then
        log_message "Session saved successfully"
        
        # Keep only last 10 session files to save space
        find "$HOME/.config" -name "konsole-session-*.json" -type f | \
            sort -r | tail -n +11 | xargs -r rm
        
        log_message "Cleaned up old session files"
    else
        log_message "ERROR: Failed to save session"
    fi
}

# Main loop
log_message "Konsole autosave daemon started (interval: ${INTERVAL}s)"

while true; do
    sleep $INTERVAL
    save_session
done
