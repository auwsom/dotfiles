#!/bin/bash
# FIXED Konsole setup with proper overlapping layout and correct user profiles
# Based on the working scripts we found

echo "Setting up 4 Konsole windows with overlapping layout..."

# Screen dimensions - updated for 3840x2050 display
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050

# Layout configuration - RESTORED WORKING OVERLAP
TITLEBAR_OFFSET=97  # Account for panels
WINDOW_WIDTH=1200
WINDOW_HEIGHT=1940  # Leave room for bottom panel
WINDOW_START_Y=$TITLEBAR_OFFSET

# Calculate positions for 4 overlapping windows
# Each window overlaps by about 25% with the next
OVERLAP_OFFSET=$((WINDOW_WIDTH / 4))  # 300 pixels overlap (1200/4)
WINDOW1_X=0
WINDOW2_X=$OVERLAP_OFFSET
WINDOW3_X=$((OVERLAP_OFFSET * 2))
WINDOW4_X=$((OVERLAP_OFFSET * 3))

echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Overlap offset: ${OVERLAP_OFFSET}px"
echo "Window 1 (Regular User): Position ($WINDOW1_X,$WINDOW_START_Y)"
echo "Window 2 (aimgr): Position ($WINDOW2_X,$WINDOW_START_Y)" 
echo "Window 3 (aimgr): Position ($WINDOW3_X,$WINDOW_START_Y)"
echo "Window 4 (aimgr): Position ($WINDOW4_X,$WINDOW_START_Y)"

# Kill existing Konsole instances
echo "Closing existing Konsole windows..."
pkill -f "konsole"
sleep 3

# Create 4 main windows with CORRECT PROFILES
echo "Creating 4 main windows..."
echo "Window 1: Regular User profile"
konsole --profile "Regular User" &
sleep 2

echo "Window 2: aimgr profile"
konsole --profile "aimgr" &
sleep 2

echo "Window 3: aimgr profile"
konsole --profile "aimgr" &
sleep 2

echo "Window 4: aimgr profile"
konsole --profile "aimgr" &
sleep 3

# Get window IDs
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Found ${#ALL_WINDOW_IDS[@]} windows: ${ALL_WINDOW_IDS[@]}"

if [ ${#ALL_WINDOW_IDS[@]} -lt 4 ]; then
    echo "Error: Expected 4 windows, got ${#ALL_WINDOW_IDS[@]}"
    exit 1
fi

# Take the last 4 (newest) windows
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")
echo "Using newest 4 windows: ${WINDOW_IDS[@]}"

# Position windows with OVERLAPPING layout
echo "Positioning windows with overlap..."
xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
echo "Window 1 positioned at ($WINDOW1_X,$WINDOW_START_Y)"

xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
echo "Window 2 positioned at ($WINDOW2_X,$WINDOW_START_Y)"

xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
echo "Window 3 positioned at ($WINDOW3_X,$WINDOW_START_Y)"

xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT
echo "Window 4 positioned at ($WINDOW4_X,$WINDOW_START_Y)"

sleep 2

# Create tabs using keyboard shortcuts
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
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
    xdotool key Return
    sleep 1.5
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
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
    xdotool key Return
    sleep 1.5
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
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
    xdotool key Return
    sleep 1.5
done

# Also set the first tab in aimgr windows
echo "Setting up first tab in aimgr windows..."
for wid in "${WINDOW_IDS[1]}" "${WINDOW_IDS[2]}" "${WINDOW_IDS[3]}"; do
    xdotool windowactivate "$wid"
    sleep 0.5
    xdotool type "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
    xdotool key Return
    sleep 1.5
done

# Activate first window
xdotool windowactivate "${WINDOW_IDS[0]}"

echo ""
echo "✅ Setup complete!"
echo "Window 1 (Regular User): 8 tabs at position $WINDOW1_X"
echo "Window 2 (aimgr): 3 tabs at position $WINDOW2_X"
echo "Window 3 (aimgr): 3 tabs at position $WINDOW3_X"
echo "Window 4 (aimgr): 3 tabs at position $WINDOW4_X"
echo ""
echo "Total windows: $(xdotool search --class "konsole" | wc -l)"
echo "Display resolution: $(xrandr | grep " connected" | grep -o "[0-9]\+x[0-9]\+" | head -1)"
