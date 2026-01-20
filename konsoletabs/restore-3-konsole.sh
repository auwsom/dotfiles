#!/bin/bash
# Restore 3 Konsole windows in horizontal layout, each taking 1/3 of screen

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2160

# Layout configuration
TITLEBAR_OFFSET=40  # Account for VM titlebar
WINDOW_WIDTH=$((SCREEN_WIDTH / 3))  # 1280 pixels each
WINDOW_HEIGHT=$((SCREEN_HEIGHT - TITLEBAR_OFFSET))  # 2120 pixels
WINDOW_START_Y=$TITLEBAR_OFFSET  # Start at 40px down

# Calculate positions
WINDOW1_X=0
WINDOW2_X=$WINDOW_WIDTH
WINDOW3_X=$((WINDOW_WIDTH * 2))

echo "Restoring 3 Konsole windows in horizontal layout..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Window 1: Position ($WINDOW1_X,$WINDOW_START_Y)"
echo "Window 2: Position ($WINDOW2_X,$WINDOW_START_Y)" 
echo "Window 3: Position ($WINDOW3_X,$WINDOW_START_Y)"

# Kill existing Konsole instances
echo "Closing existing Konsole windows..."
pkill -f "konsole" && sleep 2

# Wait for all Konsole processes to terminate
while pgrep -f "konsole" > /dev/null; do
    sleep 0.5
done

# Start 3 Konsole windows with your layout
echo "Starting new Konsole windows..."
konsole --layout "$HOME/konsole_layout1.json" &
KONSOLE1_PID=$!

sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
KONSOLE2_PID=$!

sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
KONSOLE3_PID=$!

# Wait for windows to appear
sleep 3

# Get window IDs and position them
echo "Positioning windows..."
WINDOW_IDS=($(xdotool search --class "konsole" | head -3))

if [ ${#WINDOW_IDS[@]} -eq 3 ]; then
    # Window 1 - Left third
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    # Window 2 - Middle third  
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    # Window 3 - Right third
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    echo "Successfully positioned all 3 Konsole windows!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected 3 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "Konsole layout restoration complete!"
echo "Window 1 PID: $KONSOLE1_PID"
echo "Window 2 PID: $KONSOLE2_PID" 
echo "Window 3 PID: $KONSOLE3_PID"
