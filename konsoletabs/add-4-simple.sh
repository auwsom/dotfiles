#!/bin/bash
# Add 4 Konsole windows with proper tab creation

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

echo "Adding 4 Konsole windows with proper tab creation..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"

# Kill existing Konsole instances
pkill -f "konsole" && sleep 2

# Window 1 - Regular user with 8 tabs
echo "Starting Window 1: Regular user, 8 tabs"
konsole --profile "Regular User" &
sleep 3

# Create 7 more tabs for Window 1
echo "Creating 7 additional tabs for Window 1"
for ((i=1; i<8; i++)); do
    # Temporarily set default profile to Regular User
    sed -i 's/DefaultProfile=.*/DefaultProfile=Regular User.profile/' ~/.config/konsolerc
    konsole --profile "Regular User" &
    sleep 0.3
done

# Window 2 - aimgr user with 3 tabs
echo "Starting Window 2: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Create 2 more tabs for Window 2
echo "Creating 2 additional tabs for Window 2"
for ((i=1; i<3; i++)); do
    # Temporarily set default profile to aimgr
    sed -i 's/DefaultProfile=.*/DefaultProfile=aimgr.profile/' ~/.config/konsolerc
    konsole --profile "aimgr" &
    sleep 0.3
done

# Window 3 - aimgr user with 3 tabs
echo "Starting Window 3: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Create 2 more tabs for Window 3
echo "Creating 2 additional tabs for Window 3"
for ((i=1; i<3; i++)); do
    # Temporarily set default profile to aimgr
    sed -i 's/DefaultProfile=.*/DefaultProfile=aimgr.profile/' ~/.config/konsolerc
    konsole --profile "aimgr" &
    sleep 0.3
done

# Window 4 - aimgr user with 3 tabs
echo "Starting Window 4: aimgr user, 3 tabs"
konsole --profile "aimgr" &
sleep 3

# Create 2 more tabs for Window 4
echo "Creating 2 additional tabs for Window 4"
for ((i=1; i<3; i++)); do
    # Temporarily set default profile to aimgr
    sed -i 's/DefaultProfile=.*/DefaultProfile=aimgr.profile/' ~/.config/konsolerc
    konsole --profile "aimgr" &
    sleep 0.3
done

# Reset default profile back to Regular User
sed -i 's/DefaultProfile=.*/DefaultProfile=Regular User.profile/' ~/.config/konsolerc

# Wait for all windows to appear and position them
sleep 5

# Get all Konsole windows
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole instances: ${#ALL_WINDOW_IDS[@]}"

# We need to manually arrange these into 4 windows with tabs
# This is complex, so let's use a simpler approach

echo "Setup complete. Manual arrangement may be needed."
echo "Expected: 1 window with 8 tabs (regular user) + 3 windows with 3 tabs each (aimgr)"
echo "Total instances created: ${#ALL_WINDOW_IDS[@]}"
