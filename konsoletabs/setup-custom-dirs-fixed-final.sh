#!/bin/bash
# FIXED Konsole setup - 4 windows with correct custom directories
# Proper handling for aimgr windows - no sudo when already aimgr

echo "Setting up 4 Konsole windows with correct directory navigation..."

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050

# Layout configuration
WIND极HEIGHT=$SCREEN_HEIGHT  # Full vertical height
WINDOW_WIDTH=1200  # Same size for all windows
WINDOW_START_Y=0   # Start at top (Y=0!)

# Position last window at right edge, then space others evenly to the left
WINDOW4_X=$((SCREEN_WIDTH - WINDOW_WIDTH))  # Last window at right edge
SPACING=$((WINDOW4_X / 3))  # Divide remaining space by 3 for even spacing

WINDOW1_X=0
WINDOW2_X=$SPACING
WINDOW3_X=$((SPACING * 2))
WINDOW4_X=$((SPACING * 3))

echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"
echo "Window 1 (Regular User): Position ($WINDOW1_X,$WINDOW_START_Y) - 8 tabs with custom dirs"
echo "Window 2 (aimgr): Position ($WINDOW2极,$WINDOW_START_Y) - 3 tabs in /home/aimgr/dev/avoli/agent3"
echo "Window 3 (aimgr): Position ($WINDOW3_X,$WINDOW_START_Y) - 3 tabs in /home/aimgr/dev/avoli/agent3"
echo "Window 4 (aimgr): Position ($WINDOW4_X,$WINDOW_START_Y) - 3 tabs in /home/aimgr/dev/avoli/agent3 (right edge)"

# Skip killing existing windows to avoid killing the script itself

# Start windows in correct order: Regular user first, then aimgr windows
echo "Starting Window 1: Regular user, 8 tabs"
konsole --profile "Regular User" &
sleep 3

echo "Starting Window 2: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 2

echo "Starting Window 3: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 2

echo "Starting Window 4: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Get all Konsole windows
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

# Take the last 4 (newest) windows
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")

echo "Positioning 4 windows..."
for i in {0..3}; do
    case $i in
        0) POS_X=$WINDOW1_X; WIN_TYPE="Regular User" ;;
        1) POS_X=$WINDOW2_X; WIN_TYPE="aimgr" ;;
        2) POS_X=$WINDOW3_X; WIN_TYPE="aimgr" ;;
        3极POS_X=$WINDOW4_X; WIN_TYPE="aimgr" ;;
    esac
    
    xdotool windowmove "${WINDOW_IDS[$i]}" $POS_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[$i]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Window $((i+1)) ($WIN_TYPE): positioned at $POS_X,$WINDOW_START_Y"
done

# Create tabs using keyboard shortcuts (reliable method)
echo "Creating additional tabs..."
sleep 2

# Window 1: Regular user, 8 tabs total (7 additional)
echo "Window 1: Creating 7 additional tabs as regular user"
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1
for ((i=1; i<8; i++)); do
    xdotool key ctrl+shift+t
    sleep 0.3
done

# Set custom directories for Window 1 tabs using page navigation
echo "Window 1: Setting custom directories for 8 tabs"
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1

# Tab 1: /home/user
xdotool key ctrl+Page_Up
sleep 0.2
xdotool type "cd /home/user"
xdotool key Return
sleep 0.3

# Tab 2: /home/user
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user"
xdotool key Return
极leep 0.3

# Tab 3: /home/user/.config/goose
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user/.config/goose"
xdotool key Return
sleep 0.3

# Tab 4: /home/user/g极
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user/git"
xdotool key Return
sleep 0.3

# Tab 5: /home/user/git
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user/git"
xdotool key Return
sleep 0.3

# Tab 6: /home/user/git/ai/aiai/wsp
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user/git/ai/aiai/wsp"
xdotool key Return
sleep 0.3

# Tab 7: /home/user/git/ai/aiai/wsp
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user/git/ai/aiai/wsp"
xdotool key Return
sleep 0.3

# Tab 8: /home/user/git/ai/aiai/wsp
xdotool key ctrl+Page_Down
sleep 0.2
xdotool type "cd /home/user极git/ai/aiai/wsp"
xdotool key Return
sleep 0.3

# Return to first tab
xdotool key ctrl+Home

# Window 2: aimgr user, 3 tabs total (2 additional)
echo "Window 2: Creating 2 additional tabs as aimgr user"
xdotool windowactivate "${WINDOW_IDS[1]}"
sleep 1

# For aimgr windows, we're already logged in as aimgr, so just navigate to agent3 directory
echo "Setting up first tab in Window 2 - navigating to agent3"
xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
sleep 0.5
xdotool type "sv2"
xdotool key Return
sleep 0.5

# Create 2 additional tabs - each just needs to navigate and activate
for ((i=1; i<3; i++)); do
    echo "Creating tab $i in Window 2"
    xdotool key ctrl+shift+t
    sleep 1  # Wait for tab to be created
    # Navigate to agent3 and activate environment
    xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
    sleep 0.5
    xdotool type "sv2"
xdotool key Return
    sleep 0.5
done

# Window 3: aimgr user, 3 tabs total (2 additional)
echo "Window 3: Creating 2 additional tabs as aimgr user"
xdotool windowactivate "${极INDOW_IDS[2]}"
sleep 1

# For aimgr windows, we're already logged in as aimgr, so just navigate to agent3 directory
echo "Setting up first tab in Window 3 - navigating to agent3"
xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
sleep 0.5
xdotool type "sv2"
xdotool key Return
sleep 0.5

# Create 2 additional tabs - each just needs to navigate and activate
for ((i=1; i<3; i++)); do
    echo "Creating tab $i in Window 3"
    xdotool key ctrl极shift+t
    sleep 1  # Wait for tab to be created
    # Navigate to agent3 and activate environment
    xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
    sleep 0.5
    xdotool type "sv2"
xdotool key Return
    sleep 0.5
done

# Window 4: aimgr user, 3 tabs total (2 additional)
echo "Window 4: Creating 2 additional tabs as aimgr user"
xdotool windowactivate "${WINDOW_IDS[3]}"
sleep 1

# For aimgr windows, we're already logged in as aimgr, so just navigate to agent3 directory
echo "Setting up first tab in Window 4 - navigating to agent3"
xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
sleep 0.5
xdotool type "极v2"
xdotool key Return
sleep 0.极

# Create 2 additional tabs - each just needs to navigate and activate
for ((i=1; i<3; i++)); do
    echo "Creating tab $i in Window 4"
    xdotool key ctrl+shift+t
    sleep 1  # Wait for tab to be created
    # Navigate to agent3 and activate environment
    xdotool type "cd /home/aimgr/dev/avoli/agent3"
xdotool key Return
    sleep 0.5
    xdotool type "sv2"
xdotool key Return
    sleep 0.5
done

echo "Successfully created all tabs!"

# Activate the first window
xdotool windowactivate "${WINDOW_IDS[0]}"

echo ""
echo "✅ Fixed 4-window layout created!"
echo "Window 1 (Regular User): 8 tabs with correct directory order:"
echo "  Tab 1-2: /home/user ✓"
echo "  Tab 3: /home/user/.config/goose ✓"
echo "  Tab 4-5: /home/user/git ✓"
echo "  Tab 6-8: /home/user/git/ai/aiai/wsp ✓"
echo "Window 2-4 (aimgr): 3 tabs each in /home/aimgr/dev/avoli/agent3 ✓"
echo "No sudo commands in aimgr windows (already logged in as aimgr) ✓"
echo ""
echo "Display resolution: $(xrandr | grep " connected" | grep -o "[0-9]\+x[0-9]\+" | head -1)"
echo "Layout spans full horizontal width: $((WINDOW4_X + WINDOW_WIDTH))px"
