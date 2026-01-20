#!/bin/bash
# Wrapper script that keeps the terminal open with a graphical dialog

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

# Run the actual script
"$@"

RESULT=$?

# Show completion dialog
if command -v kdialog >/dev/null 2>&1; then
    kdialog --msgbox "Script completed with exit code: $RESULT\n\nClick OK to close this window." --title "Konsole Layout"
else
    echo ""
    echo "=== Script Complete ==="
    echo "Exit code: $RESULT"
    echo ""
    echo "This window will stay open for 2 minutes..."
    echo "You can close it anytime with Ctrl+C or the X button."
    sleep 120
fi

exit $RESULT
