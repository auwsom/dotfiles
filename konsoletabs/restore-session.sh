#!/bin/bash
# Restore Konsole session from saved state

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "=== Restore Konsole Session ==="
echo ""

echo "Checking for saved session..."
SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ -f "$SESSION_FILE" ]; then
    echo "Found session file, attempting restore..."
    "$SCRIPT_DIR/restore-session-auto.sh"
    if [ $? -eq 0 ]; then
        echo "✅ Session restored successfully"
    else
        echo "⚠️ Restore had issues, creating fresh layout..."
        "$SCRIPT_DIR/setup-working-width.sh"
    fi
else
    echo "No session file found, creating fresh layout..."
    "$SCRIPT_DIR/setup-working-width.sh"
fi

echo ""
echo "Done! Press Enter to close..."
read input
