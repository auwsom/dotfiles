#!/bin/bash
# Add 4 overlapping Konsole windows without killing anything

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2160

# Layout configuration
TITLEBAR_OFFSET=40
WINDOW_WIDTH=1400
WINDOW_HEIGHT=2000
WINDOW_START_Y=$TITLEBAR_OFFSET

# Calculate positions for 4 overlapping windows
OVERLAP_OFFSET=$((WINDOW_WIDTH / 4))  # 350 pixels overlap
WINDOW1_X=0
WINDOW2_X=$OVERLAP_OFFSET
WINDOW3_X=$((OVERLAP_OFFSET * 2))
WINDOW4_X=$((OVERLAP_OFFSET * 3))

echo "Adding 4 overlapping Konsole windows..."
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Window 1: Position ($WINDOW1_X,$WINDOW_START_Y)"
echo "Window 2: Position ($WINDOW2_X,$WINDOW_START_Y)" 
echo "Window 3: Position ($WINDOW3_X,$WINDOW_START_Y)"
echo "Window 4: Position ($WINDOW4_X,$WINDOW_START_Y)"

# Start 4 new Konsole windows
echo "Starting 4 new Konsole windows..."
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &

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
    echo "Positioned window ${WINDOW_IDS[0]} at ($WINDOW1_X,$WINDOW_START_Y)"
    
    # Window 2 - Overlapping with window 1
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[1]} at ($WINDOW2_X,$WINDOW_START_Y)"
    
    # Window 3 - Overlapping with window 2
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[2]} at ($WINDOW3_X,$WINDOW_START_Y)"
    
    # Window 4 - Rightmost
    xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[3]} at ($WINDOW4_X,$WINDOW_START_Y)"
    
    echo "Successfully positioned all 4 overlapping Konsole windows!"
    
    # Activate the first new window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 4 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "4 overlapping Konsole windows added successfully!"
