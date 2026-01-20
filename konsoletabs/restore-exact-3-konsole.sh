#!/bin/bash
# Restore your exact 3-window Konsole layout

# Your exact saved positions
WINDOW1_ID=18874379
WINDOW1_X=0
WINDOW1_Y=134
WINDOW1_WIDTH=1036
WINDOW1_HEIGHT=1990

WINDOW2_ID=18874419
WINDOW2_X=1294
WINDOW2_Y=134
WINDOW2_WIDTH=1256
WINDOW2_HEIGHT=1990

WINDOW3_ID=18874662
WINDOW3_X=2551
WINDOW3_Y=134
WINDOW3_WIDTH=1324
WINDOW3_HEIGHT=1990

echo "Restoring your exact 3-window Konsole layout..."
echo "Window 1: Position ($WINDOW1_X,$WINDOW1_Y) size ${WINDOW1_WIDTH}x${WINDOW1_HEIGHT}"
echo "Window 2: Position ($WINDOW2_X,$WINDOW2_Y) size ${WINDOW2_WIDTH}x${WINDOW2_HEIGHT}"
echo "Window 3: Position ($WINDOW3_X,$WINDOW3_Y) size ${WINDOW3_WIDTH}x${WINDOW3_HEIGHT}"

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
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --layout "$HOME/konsole_layout1.json" &

# Wait for windows to appear
sleep 3

# Get window IDs and position them
echo "Positioning windows..."
WINDOW_IDS=($(xdotool search --class "konsole" | head -3))

if [ ${#WINDOW_IDS[@]} -eq 3 ]; then
    # Window 1 - Left position
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW1_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW1_WIDTH $WINDOW1_HEIGHT
    
    # Window 2 - Middle position  
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW2_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW2_WIDTH $WINDOW2_HEIGHT
    
    # Window 3 - Right position
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW3_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW3_WIDTH $WINDOW3_HEIGHT
    
    echo "Successfully positioned all 3 Konsole windows!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected 3 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "Konsole layout restoration complete!"
