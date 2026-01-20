#!/bin/bash
# Simple restore that modifies the working setup script

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

# Get saved directories
SAVED_DIRS=$(python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)
dirs = [w['working_directory'] for w in session['windows']]
for d in dirs:
    print(d)
")

echo "Saved directories:"
echo "$SAVED_DIRS" | nl -nln

echo ""
echo "Creating fresh layout with saved directories..."
echo ""

# Kill existing windows first
pkill -f konsole
sleep 2

# Run the working setup script and wait for it to complete
echo "Running fresh layout setup..."
/home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working

# Wait a bit for everything to stabilize
sleep 3

# Now change directories in the created windows
echo "Changing directories to saved locations..."

# Get window IDs
WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null | tail -4))

if [ ${#WINDOW_IDS[@]} -ge 4 ]; then
    # Change directory in each window
    i=0
    for dir in $SAVED_DIRS; do
        if [ $i -lt 4 ]; then
            echo "Window $((i+1)): changing to $dir"
            xdotool windowactivate "${WINDOW_IDS[$i]}"
            sleep 1
            xdotool type "cd $dir"
            xdotool key Return
            sleep 0.5
        fi
        ((i++))
    done
    
    echo "✅ Directories restored!"
else
    echo "Error: Could not find 4 windows"
fi

echo ""
echo "Press Enter to close..."
read input
