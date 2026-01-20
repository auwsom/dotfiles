#!/bin/bash
# Restore Konsole session with sudo (for elevated privileges if needed)
# This script will prompt for password when needed

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "Restoring Konsole session..."
echo "You may be prompted for password if elevated privileges are needed."
echo ""

# Try to run without sudo first
if "$SCRIPT_DIR/konsole-manager.sh" restore; then
    echo "✅ Session restored successfully"
else
    echo "⚠️  Trying with sudo..."
    sudo "$SCRIPT_DIR/konsole-manager.sh" restore
    if [ $? -eq 0 ]; then
        echo "✅ Session restored successfully with sudo"
    else
        echo "❌ Failed to restore session"
    fi
fi

echo ""
echo "Done! Press Enter to close this window..."
read input
