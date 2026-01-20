#!/bin/bash
# Create fresh Konsole layout

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "=== Create Fresh Konsole Layout ==="
echo ""

echo "Creating fresh 4-window layout..."
"$SCRIPT_DIR/setup-working-width.sh.working"

RESULT=$?
echo ""
if [ $RESULT -eq 0 ]; then
    echo "✅ Fresh layout created successfully"
else
    echo "⚠️ Layout creation had some issues, but windows may have been created"
fi

echo ""
echo "Total windows created: $(xdotool search --class "konsole" 2>/dev/null | wc -l)"
echo ""
echo "Press Enter to close this window..."
read input
