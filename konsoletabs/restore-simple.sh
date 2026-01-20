#!/bin/bash
# Simple restore - just create fresh layout

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "=== Restore Konsole Session ==="
echo ""

echo "Creating fresh 4-window layout..."
"$SCRIPT_DIR/setup-working-width.sh.working"

RESULT=$?
echo ""
if [ $RESULT -eq 0 ]; then
    echo "✅ Layout created successfully"
else
    echo "⚠️ Layout creation had some issues, but windows may have been created"
fi

echo ""
echo "Total windows created: $(xdotool search --class "konsole" 2>/dev/null | wc -l)"
echo ""
echo "Restore complete. This window will stay open for 60 seconds..."
echo "You can close it anytime with Ctrl+C or the X button."
sleep 60
