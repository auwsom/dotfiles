#!/bin/bash
# Simple restore script that waits for user input

SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"

echo "=== Konsole Session Restore ==="
echo ""

echo "Choose an option:"
echo "1. Restore saved session"
echo "2. Create fresh layout"
echo "3. Exit"
echo ""
echo -n "Enter choice (1-3): "
read choice

case $choice in
    1)
        echo ""
        echo "Restoring saved session..."
        "$SCRIPT_DIR/konsole-manager.sh" restore
        ;;
    2)
        echo ""
        echo "Creating fresh layout..."
        "$SCRIPT_DIR/setup-working-width.sh"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo ""
echo "Operation completed. Press Enter to close..."
read input
