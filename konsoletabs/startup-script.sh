#!/bin/bash
# Startup script for Konsole session management
# This script runs on login to set up the environment

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"
LOG_FILE="$HOME/.config/konsole-startup.log"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "=== Konsole Startup Script Started ==="

# Step 1: Force set display resolution
log_message "Force setting display resolution..."
sleep 3  # Wait for display system to be ready
if "$SCRIPT_DIR/force-display-resolution.sh" >> "$LOG_FILE" 2>&1; then
    log_message "✅ Display resolution set successfully"
else
    log_message "❌ Failed to set display resolution"
fi

# Step 2: Start autosave daemon
log_message "Starting autosave daemon..."
sleep 5  # Give system time to settle
if "$SCRIPT_DIR/autosave-control.sh" start >> "$LOG_FILE" 2>&1; then
    log_message "✅ Autosave daemon started"
else
    log_message "⚠️ Autosave daemon may already be running"
fi

# Step 3: Restore Konsole session (optional - uncomment if you want automatic restore)
# log_message "Restoring Konsole session..."
# sleep 2  # Wait for display to be ready
# if "$SCRIPT_DIR/konsole-manager.sh" restore >> "$LOG_FILE" 2>&1; then
#     log_message "✅ Konsole session restored"
# else
#     log_message "❌ Failed to restore Konsole session"
# fi

log_message "=== Startup Script Completed ==="

echo "Startup tasks completed. Check $LOG_FILE for details."
