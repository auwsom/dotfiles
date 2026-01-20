#!/bin/bash
# Test xdotool directory change in existing windows

echo "Testing xdotool directory change..."

# Start fresh layout first (this works)
echo "Starting fresh layout..."
/home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working

echo ""
echo "Layout created. Now testing directory changes..."
sleep 2

# Get window IDs
WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))

echo "Found ${#WINDOW_IDS[@]} windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ge 2 ]; then
    echo "Testing Window 2: changing to /home/user"
    xdotool windowactivate "${WINDOW_IDS[1]}"
    sleep 1
    
    # Type the cd command
    xdotool type "cd /home/user"
    xdotool key Return
    sleep 1
    
    # Check if it worked by typing pwd
    xdotool type "pwd"
    xdotool key Return
    
    echo "Check Window 2 - it should show /home/user"
else
    echo "Not enough windows found"
fi

echo ""
echo "Press Enter to close..."
read input
