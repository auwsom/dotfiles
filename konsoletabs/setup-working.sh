#!/bin/bash
# Working Konsole setup - simplified and fixed

echo "Setting up 4 Konsole windows with tabs..."

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050
WINDOW_WIDTH=1200
WINDOW_HEIGHT=$SCREEN_HEIGHT
WINDOW_START_Y=0

# Calculate positions
WINDOW4_X=$((SCREEN_WIDTH - WINDOW_WIDTH))
SPACING=$((WINDOW4_X / 3))

WINDOW1_X=0
WINDOW2_X=$SPACING
WINDOW3_X=$((SPACING * 2))
WINDOW4_X=$((SPACING * 3))

echo "Layout: ${WINDOW_WIDTH}x${WINDOW_HEIGHT} each, spacing ${SPACING}px"

# Kill existing Konsole instances
pkill -f "konsole"
sleep 2

# Create 4 main windows
echo "Creating 4 main windows..."
konsole --profile "Regular User" &
sleep 2
konsole --profile "aimgr" &
sleep 2
konsole --profile "aimgr" &
sleep 2
konsole --profile "aimgr" &
sleep 3

# Get window IDs
WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Found ${#WINDOW_IDS[@]} windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -lt 4 ]; then
    echo "Error: Expected 4 windows, got ${#WINDOW_IDS[@]}"
    exit 1
fi

# Position windows
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

# Create tabs using keyboard shortcuts with proper user switching
echo "Creating tabs..."

# Window 1: Regular user, 8 tabs total
echo "Window 1: Creating 7 additional tabs..."
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1
for i in {1..7}; do
    echo "  Tab $i"
    xdotool key ctrl+shift+t
    sleep 0.3
done

# Window 2: aimgr user, 3 tabs total
echo "Window 2: Creating 2 additional tabs with aimgr user..."
xdotool windowactivate "${WINDOW_IDS[1]}"
sleep 1
for i in {1..2}; do
    echo "  Tab $i"
    xdotool key ctrl+shift+t
    sleep 0.5
    # Manually switch to aimgr user and activate sv2
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

# Window 3: aimgr user, 3 tabs total
echo "Window 3: Creating 2 additional tabs with aimgr user..."
xdotool windowactivate "${WINDOW_IDS[2]}"
sleep 1
for i in {1..2}; do
    echo "  Tab $i"
    xdotool key ctrl+shift+t
    sleep 0.5
    # Manually switch to aimgr user and activate sv2
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

# Window 4: aimgr user, 3 tabs total
echo "Window 4: Creating 2 additional tabs with aimgr user..."
xdotool windowactivate "${WINDOW_IDS[3]}"
sleep 1
for i in {1..2}; do
    echo "  Tab $i"
    xdotool key ctrl+shift+t
    sleep 0.5
    # Manually switch to aimgr user and activate sv2
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

# Activate first window
xdotool windowactivate "${WINDOW_IDS[0]}"

echo ""
echo "Setup complete!"
echo "Window 1 (Regular User): 8 tabs"
echo "Window 2-4 (aimgr): 3 tabs each"
echo "Total windows: $(xdotool search --class "konsole" | wc -l)"
