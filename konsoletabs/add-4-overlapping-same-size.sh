#!/bin/bash
# Add 4 overlapping Konsole windows - same size, evenly spaced, last at right edge

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

echo "Adding 4 overlapping Konsole windows..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"
echo "Window 1: Position ($WINDOW1_X,$WINDOW_START_Y)"
echo "Window 2: Position ($WINDOW2_X,$WINDOW_START_Y)" 
echo "Window 3: Position ($WINDOW3_X,$WINDOW_START_Y)"
echo "Window 4: Position ($WINDOW4_X,$WINDOW_START_Y) (right edge)"

# Start 4 new Konsole windows with aimgr user profile
echo "Starting 4 new Konsole windows with aimgr user..."
konsole --profile "aimgr" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "aimgr" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "aimgr" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "aimgr" --layout "$HOME/konsole_layout1.json" &

# Wait for windows to appear
sleep 3

# Get all Konsole windows
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

# Take the last 4 (newest) windows
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")

echo "Positioning newest 4 windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ge 4 ]; then
    # Window 1 - Leftmost
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[0]} at ($WINDOW1_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 2 - First spacing
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[1]} at ($WINDOW2_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 3 - Second spacing
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[2]} at ($WINDOW3_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 4 - Right edge
    xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[3]} at ($WINDOW4_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    echo "Successfully positioned all 4 overlapping Konsole windows!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 4 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "4 overlapping Konsole windows added successfully!"
