#!/bin/bash
# Add 4 Konsole windows with proper aimgr tab creation

# Screen dimensions - updated for VM
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050

# Layout configuration
WINDOW_HEIGHT=$SCREEN_HEIGHT  # Full vertical height
WINDOW_WIDTH=1200  # Same size for all windows
WINDOW_START_Y=0   # Start at top

# Position last window at right edge, then space others evenly to the left
WINDOW4_X=$((SCREEN_WIDTH - WINDOW_WIDTH))  # Last window at right edge
SPACING=$((WINDOW4_X / 3))  # Divide remaining space by 3 for even spacing

WINDOW1_X=0
WINDOW2_X=$SPACING
WINDOW3_X=$((SPACING * 2))
WINDOW4_X=$((SPACING * 3))

echo "Adding 4 Konsole windows with proper aimgr tab creation..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"

# Kill existing Konsole instances
pkill -f "konsole" && sleep 2

# Function to create tabs with proper profile
create_tabs_in_window() {
    local window_id=$1
    local profile=$2
    local num_tabs=$3
    
    echo "Creating $num_tabs tabs in window $window_id with profile $profile"
    
    # Activate the window
    xdotool windowactivate "$window_id"
    sleep 0.5
    
    # Create additional tabs
    for ((i=1; i<num_tabs; i++)); do
        # Temporarily change default profile
        if [ "$profile" = "aimgr" ]; then
            sed -i 's/DefaultProfile=.*/DefaultProfile=aimgr.profile/' ~/.config/konsolerc
        else
            sed -i 's/DefaultProfile=.*/DefaultProfile=Regular User.profile/' ~/.config/konsolerc
        fi
        
        # Create new tab
        xdotool key --delay 200 ctrl+shift+t
        sleep 0.5
        
        # If aimgr, run the aimgr command manually
        if [ "$profile" = "aimgr" ]; then
            xdotool key --delay 200 "sudo -u aimgr bash -c 'cd /home/aimgr/dev/avoli && exec bash'"
            xdotool key --delay 100 Return
            sleep 0.5
            xdotool key --delay 200 "sv2"
            xdotool key --delay 100 Return
            sleep 0.5
        fi
    done
    
    # Reset default profile
    sed -i 's/DefaultProfile=.*/DefaultProfile=Regular User.profile/' ~/.config/konsolerc
}

# Window 1 - Regular user with 8 tabs
echo "Starting Window 1: Regular user, 8 tabs"
konsole --profile "Regular User" &
sleep 3

# Window 2 - aimgr user with 3 tabs
echo "Starting Window 2: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Window 3 - aimgr user with 3 tabs
echo "Starting Window 3: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Window 4 - aimgr user with 3 tabs
echo "Starting Window 4: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Get all Konsole windows and position them
echo "Getting window IDs and positioning..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

if [ ${#ALL_WINDOW_IDS[@]} -ge 4 ]; then
    # Position all windows
    xdotool windowmove "${ALL_WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
    xdotool windowsize "${ALL_WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    xdotool windowmove "${ALL_WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${ALL_WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    xdotool windowmove "${ALL_WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${ALL_WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    xdotool windowmove "${ALL_WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
    xdotool windowsize "${ALL_WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    echo "Windows positioned successfully"
    
    # Wait for windows to stabilize
    sleep 2
    
    # Create tabs in each window
    create_tabs_in_window "${ALL_WINDOW_IDS[0]}" "Regular User" 8
    create_tabs_in_window "${ALL_WINDOW_IDS[1]}" "aimgr" 3
    create_tabs_in_window "${ALL_WINDOW_IDS[2]}" "aimgr" 3
    create_tabs_in_window "${ALL_WINDOW_IDS[3]}" "aimgr" 3
    
    # Activate the first window
    xdotool windowactivate "${ALL_WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 4 Konsole windows, found ${#ALL_WINDOW_IDS[@]}"
    exit 1
fi

echo "4 Konsole windows with custom tab configurations added successfully!"
echo "Window 1: Regular user, 8 tabs"
echo "Window 2-4: aimgr user, 3 tabs each with sv2 activated"
