#!/bin/bash
# Save current Konsole session manually

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "=== Save Konsole Session ==="
echo ""

echo "Saving current session..."
if "$SCRIPT_DIR/konsole-manager.sh" save; then
    echo "✅ Session saved successfully"
else
    echo "❌ Failed to save session"
    echo "Trying advanced save..."
    "$SCRIPT_DIR/konsole-manager.sh" save-adv
fi

echo ""
echo "Done! Press Enter to close..."
read input
