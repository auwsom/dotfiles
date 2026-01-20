#!/bin/bash
# Add 4 Konsole windows with different tab configurations

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

echo "Adding 4 Konsole windows with custom tab configurations..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"
echo "Window 1: Position ($WINDOW1_X,$WINDOW_START_Y) - Regular user, 8 tabs"
echo "Window 2: Position ($WINDOW2_X,$WINDOW_START_Y) - aimgr user, 3 tabs" 
echo "Window 3: Position ($WINDOW3_X,$WINDOW_START_Y) - aimgr user, 3 tabs"
echo "Window 4: Position ($WINDOW4_X,$WINDOW_START_Y) - aimgr user, 3 tabs (right edge)"

# Function to create tabs in a window
create_tabs() {
    local profile=$1
    local num_tabs=$2
    local window_id=$3
    
    echo "Creating $num_tabs tabs in window $window_id with profile $profile"
    
    # Create additional tabs (first tab already exists)
    for ((i=2; i<=num_tabs; i++)); do
        qdbus org.kde.konsole /Sessions/newSession > /dev/null 2>&1
        sleep 0.1
    done
}

# Start windows in order: Regular user first, then aimgr windows
# Window 1 - Regular user with 8 tabs (start this first)
echo "Starting Window 1: Regular user, 8 tabs"
konsole --profile "Regular User" &
WINDOW1_PID=$!
sleep 3  # Give it more time to fully initialize

# Window 2 - aimgr user with 3 tabs
echo "Starting Window 2: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW2_PID=$!
sleep 2

# Window 3 - aimgr user with 3 tabs
echo "Starting Window 3: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW3_PID=$!
sleep 2

# Window 4 - aimgr user with 3 tabs
echo "Starting Window 4: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW4_PID=$!
sleep 3

# Wait for all windows to appear
sleep 3

# Get all Konsole windows
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

# Take the last 4 (newest) windows
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")

echo "Positioning newest 4 windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ge 4 ]; then
    # Position all windows first
    # Window 1 - Regular user
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[0]} at ($WINDOW1_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 2 - aimgr user
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[1]} at ($WINDOW2_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 3 - aimgr user
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[2]} at ($WINDOW3_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 4 - aimgr user
    xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[3]} at ($WINDOW4_X,$WINDOW_START_Y) size ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
    
    # Wait a bit for windows to stabilize
    sleep 2
    
    # Create additional tabs using DBus instead of keyboard shortcuts
    echo "Creating additional tabs..."
    
    # Window 1: Add 7 more tabs (total 8) - ensure it stays as regular user
    xdotool windowactivate "${WINDOW_IDS[0]}"
    sleep 0.5
    echo "Window 1: Creating 7 additional tabs as regular user"
    for ((i=1; i<8; i++)); do
        # Create new session with Regular User profile
        qdbus org.kde.konsole /Konsole org.kde.Konsole.newSession "Regular User" > /dev/null 2>&1
        sleep 0.3
    done
    
    # Verify Window 1 is still regular user
    sleep 1
    xdotool windowactivate "${WINDOW_IDS[0]}"
    xdotool key --delay 200 "whoami"
    xdotool key --delay 100 Return
    sleep 0.5
    
    # Window 2: Add 2 more tabs (total 3) - aimgr user with sv2
    xdotool windowactivate "${WINDOW_IDS[1]}"
    sleep 0.5
    echo "Window 2: Creating 2 additional tabs as aimgr user"
    for ((i=1; i<3; i++)); do
        # Create new session with aimgr profile
        qdbus org.kde.konsole /Konsole org.kde.Konsole.newSession "aimgr" > /dev/null 2>&1
        sleep 0.3
    done
    
    # Verify Window 2 is aimgr user and activate sv2
    sleep 1
    xdotool windowactivate "${WINDOW_IDS[1]}"
    xdotool key --delay 200 "whoami"
    xdotool key --delay 100 Return
    sleep 0.5
    xdotool key --delay 200 "sv2"
    xdotool key --delay 100 Return
    sleep 0.5
    
    # Window 3: Add 2 more tabs (total 3) - aimgr user with sv2
    xdotool windowactivate "${WINDOW_IDS[2]}"
    sleep 0.5
    echo "Window 3: Creating 2 additional tabs as aimgr user"
    for ((i=1; i<3; i++)); do
        # Create new session with aimgr profile
        qdbus org.kde.konsole /Konsole org.kde.Konsole.newSession "aimgr" > /dev/null 2>&1
        sleep 0.3
    done
    
    # Verify Window 3 is aimgr user and activate sv2
    sleep 1
    xdotool windowactivate "${WINDOW_IDS[2]}"
    xdotool key --delay 200 "whoami"
    xdotool key --delay 100 Return
    sleep 0.5
    xdotool key --delay 200 "sv2"
    xdotool key --delay 100 Return
    sleep 0.5
    
    # Window 4: Add 2 more tabs (total 3) - aimgr user with sv2
    xdotool windowactivate "${WINDOW_IDS[3]}"
    sleep 0.5
    echo "Window 4: Creating 2 additional tabs as aimgr user"
    for ((i=1; i<3; i++)); do
        # Create new session with aimgr profile
        qdbus org.kde.konsole /Konsole org.kde.Konsole.newSession "aimgr" > /dev/null 2>&1
        sleep 0.3
    done
    
    # Verify Window 4 is aimgr user and activate sv2
    sleep 1
    xdotool windowactivate "${WINDOW_IDS[3]}"
    xdotool key --delay 200 "whoami"
    xdotool key --delay 100 Return
    sleep 0.5
    xdotool key --delay 200 "sv2"
    xdotool key --delay 100 Return
    sleep 0.5
    
    echo "Successfully created all tabs!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 4 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "4 Konsole windows with custom tab configurations added successfully!"
echo "Window 1: Regular user, 8 tabs"
echo "Window 2-4: aimgr user, 3 tabs each"
