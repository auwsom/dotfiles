#!/bin/bash
# Smart Konsole autosave daemon - only saves when session actually changes
# This prevents duplicate saves and saves disk space

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.config/konsole-autosave.log"
LAST_SESSION_FILE="$HOME/.config/.konsole-last-session"
INTERVAL=300  # 5 minutes in seconds (reduced for more responsiveness)
MAX_SESSIONS=10  # Keep only last 10 session files

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to get current session fingerprint
get_session_fingerprint() {
    # Use qdbus if available, otherwise fallback to process detection
    if qdbus org.kde.konsole >/dev/null 2>&1; then
        # Get session info via DBus
        qdbus org.kde.konsole 2>/dev/null | grep "/Sessions/" | sort | md5sum | cut -d' ' -f1
    else
        # Fallback to process-based detection
        pgrep -f "konsole" | sort | md5sum | cut -d' ' -f1
    fi
}

# Function to save session
save_session() {
    local current_fingerprint="$1"
    
    log_message "Session changed, saving..."
    
    # Save the session
    if "$SCRIPT_DIR/save-session-advanced.sh" > /dev/null 2>&1; then
        # Update last session fingerprint
        echo "$current_fingerprint" > "$LAST_SESSION_FILE"
        
        # Clean up old session files, keep only the most recent MAX_SESSIONS
        local session_count=$(find "$HOME/.config" -name "konsole-session-*.json" -type f | wc -l)
        if [ $session_count -gt $MAX_SESSIONS ]; then
            local files_to_remove=$((session_count - MAX_SESSIONS))
            find "$HOME/.config" -name "konsole-session-*.json" -type f | \
                sort | head -n "$files_to_remove" | xargs -r rm -f
            log_message "Cleaned up $files_to_remove old session files, keeping $MAX_SESSIONS"
        fi
        
        log_message "Session saved successfully ($(find "$HOME/.config" -name "konsole-session-*.json" -type f | wc -l) files total)"
        return 0
    else
        log_message "ERROR: Failed to save session"
        return 1
    fi
}

# Initialize last session fingerprint if it doesn't exist
if [ ! -f "$LAST_SESSION_FILE" ]; then
    get_session_fingerprint > "$LAST_SESSION_FILE"
    log_message "Initialized session fingerprint tracking"
fi

# Main loop
log_message "Smart Konsole autosave daemon started (interval: ${INTERVAL}s, max sessions: $MAX_SESSIONS)"

while true; do
    sleep $INTERVAL
    
    # Get current session fingerprint
    current_fingerprint=$(get_session_fingerprint)
    
    # Get last saved fingerprint
    last_fingerprint=$(cat "$LAST_SESSION_FILE" 2>/dev/null || echo "")
    
    # Compare fingerprints
    if [ "$current_fingerprint" != "$last_fingerprint" ]; then
        save_session "$current_fingerprint"
    else
        log_message "Session unchanged, skipping save"
    fi
done
