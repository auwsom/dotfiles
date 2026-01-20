#!/bin/bash
# Safe restore of 3-window Konsole layout (doesn't kill current session)

# Your exact saved positions
WINDOW1_X=0
WINDOW1_Y=134
WINDOW1_WIDTH=1036
WINDOW1_HEIGHT=1990

WINDOW2_X=1294
WINDOW2_Y=134
WINDOW2_WIDTH=1256
WINDOW2_HEIGHT=1990

WINDOW3_X=2551
WINDOW3_Y=134
WINDOW3_WIDTH=1324
WINDOW3_HEIGHT=1990

echo "Restoring your exact 3-window Konsole layout..."
echo "Window 1: Position ($WINDOW1_X,$WINDOW1_Y) size ${WINDOW1_WIDTH}x${WINDOW1_HEIGHT}"
echo "Window 2: Position ($WINDOW2_X,$WINDOW2_Y) size ${WINDOW2_WIDTH}x${WINDOW2_HEIGHT}"
echo "Window 3: Position ($WINDOW3_X,$WINDOW3_Y) size ${WINDOW3_WIDTH}x${WINDOW3_HEIGHT}"

# Count current Konsole windows
CURRENT_COUNT=$(xdotool search --class "konsole" | wc -l)
echo "Current Konsole windows: $CURRENT_COUNT"

if [ "$CURRENT_COUNT" -gt 0 ]; then
    echo "Found existing Konsole windows. Would you like to:"
    echo "1. Close all and start fresh"
    echo "2. Keep existing and add new windows"
    echo "3. Cancel"
    read -p "Choose (1/2/3): " choice
    
    case $choice in
        1)
            echo "Closing existing Konsole windows..."
            pkill -f "konsole" && sleep 2
            while pgrep -f "konsole" > /dev/null; do sleep 0.5; done
            ;;
        2)
            echo "Keeping existing windows and adding new ones..."
            ;;
        3)
            echo "Cancelled."
            exit 0
            ;;
        *)
            echo "Invalid choice. Keeping existing windows..."
            ;;
    esac
fi

# Start 3 Konsole windows with your layout
echo "Starting new Konsole windows..."
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &

# Wait for windows to appear
sleep 3

# Get the newest 3 window IDs
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole"))
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -3}")  # Get last 3 windows

echo "Found ${#WINDOW_IDS[@]} windows to position: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ge 3 ]; then
    # Window 1 - Left position
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW1_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW1_WIDTH $WINDOW1_HEIGHT
    echo "Positioned window ${WINDOW_IDS[0]} at ($WINDOW1_X,$WINDOW1_Y)"
    
    # Window 2 - Middle position  
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW2_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW2_WIDTH $WINDOW2_HEIGHT
    echo "Positioned window ${WINDOW_IDS[1]} at ($WINDOW2_X,$WINDOW2_Y)"
    
    # Window 3 - Right position
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW3_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW3_WIDTH $WINDOW3_HEIGHT
    echo "Positioned window ${WINDOW_IDS[2]} at ($WINDOW3_X,$WINDOW3_Y)"
    
    echo "Successfully positioned all 3 Konsole windows!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 3 Konsole windows, found ${#WINDOW_IDS[@]}"
    echo "Available windows: ${ALL_WINDOW_IDS[@]}"
    exit 1
fi

echo "Konsole layout restoration complete!"
