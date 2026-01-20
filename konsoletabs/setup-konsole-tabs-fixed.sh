#!/bin/bash
# Add 4 Konsole windows with proper tab creation - FIXED VERSION

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

echo "Setting up 4 Konsole windows with proper tabs..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"

# Kill existing Konsole instances
pkill -f "konsole" && sleep 2

# Create 4 main windows first
echo "Creating 4 main windows..."
konsole --profile "Regular User" &
W1_PID=$!
sleep 2

konsole --profile "aimgr" &
W2_PID=$!
sleep 2

konsole --profile "aimgr" &
W3_PID=$!
sleep 2

konsole --profile "aimgr" &
W4_PID=$!
sleep 3

# Get the 4 window IDs
echo "Getting window IDs..."
WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null | head -4))
echo "Found ${#WINDOW_IDS[@]} windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ne 4 ]; then
    echo "Error: Expected 4 windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

# Position the 4 main windows
echo "Positioning windows..."
xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT

xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT

xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT

xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT

sleep 2

# Function to create tabs in a specific window
create_tabs_in_window() {
    local window_id=$1
    local profile=$2
    local num_tabs=$3
    
    echo "Creating $((num_tabs-1)) additional tabs in window $window_id ($profile)"
    
    # Activate the window
    xdotool windowactivate "$window_id"
    sleep 0.5
    
    # Create additional tabs using keyboard shortcuts
    for ((i=1; i<num_tabs; i++)); do
        echo "  Creating tab $i..."
        xdotool key --delay 150 ctrl+shift+t
        sleep 0.5
        
        # If this is an aimgr window, run the aimgr setup commands
        if [ "$profile" = "aimgr" ]; then
            echo "  Setting up aimgr user and sv2..."
            # Run the aimgr setup commands
            xdotool type --delay 100 "sudo -u aimgr bash -c 'cd ~/dev/avoli && exec bash'"
            xdotool key --delay 100 Return
            sleep 1
            
            # Activate sv2
            xdotool type --delay 100 "sv2"
            xdotool key --delay 100 Return
            sleep 0.5
        fi
    done
}

# Create tabs in each window
echo "Creating tabs..."

# Window 1: Regular user, 8 tabs total (7 additional)
create_tabs_in_window "${WINDOW_IDS[0]}" "Regular User" 8

# Window 2: aimgr user, 3 tabs total (2 additional)
create_tabs_in_window "${WINDOW_IDS[1]}" "aimgr" 3

# Window 3: aimgr user, 3 tabs total (2 additional)
create_tabs_in_window "${WINDOW_IDS[2]}" "aimgr" 3

# Window 4: aimgr user, 3 tabs total (2 additional)
create_tabs_in_window "${WINDOW_IDS[3]}" "aimgr" 3

# Verify the setup
echo ""
echo "Verifying setup..."
sleep 2

# Check final window count
FINAL_WINDOWS=$(xdotool search --class "konsole" | wc -l)
echo "Final Konsole windows: $FINAL_WINDOWS (should be 4)"

# Check processes per window
for i in "${!WINDOW_IDS[@]}"; do
    WID="${WINDOW_IDS[$i]}"
    # Get sessions for this window
    SESSIONS=$(qdbus org.kde.konsole /Sessions/listSessions 2>/dev/null | wc -l)
    echo "Window $((i+1)): $SESSIONS sessions"
done

# Activate the first window
xdotool windowactivate "${WINDOW_IDS[0]}"

echo ""
echo "Setup complete!"
echo "Window 1: Regular user, 8 tabs"
echo "Window 2-4: aimgr user, 3 tabs each with sv2"
