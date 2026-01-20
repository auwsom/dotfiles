#!/bin/bash
# Add 4 Konsole windows with correct tab profiles using individual instances

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

echo "Adding 4 Konsole windows with individual tab instances..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Spacing between starts: ${SPACING}px"
echo "Window 1: Position ($WINDOW1_X,$WINDOW_START_Y) - Regular user, 8 tabs"
echo "Window 2: Position ($WINDOW2_X,$WINDOW_START_Y) - aimgr user, 3 tabs" 
echo "Window 3: Position ($WINDOW3_X,$WINDOW_START_Y) - aimgr user, 3 tabs"
echo "Window 4: Position ($WINDOW4_X,$WINDOW_START_Y) - aimgr user, 3 tabs (right edge)"

# Kill existing Konsole instances
pkill -f "konsole" && sleep 2

# Window 1 - Regular user with 8 tabs (start this first)
echo "Starting Window 1: Regular user, 8 tabs"
konsole --profile "Regular User" &
WINDOW1_PID=$!
sleep 3

# Create 7 more tabs for Window 1 using new instances
for ((i=1; i<8; i++)); do
    konsole --profile "Regular User" &
    sleep 0.2
done

# Window 2 - aimgr user with 3 tabs
echo "Starting Window 2: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW2_PID=$!
sleep 2

# Create 2 more tabs for Window 2
for ((i=1; i<3; i++)); do
    konsole --profile "aimgr" &
    sleep 0.2
done

# Window 3 - aimgr user with 3 tabs
echo "Starting Window 3: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW3_PID=$!
sleep 2

# Create 2 more tabs for Window 3
for ((i=1; i<3; i++)); do
    konsole --profile "aimgr" &
    sleep 0.2
done

# Window 4 - aimgr user with 3 tabs
echo "Starting Window 4: aimgr user, 3 tabs"
konsole --profile "aimgr" &
WINDOW4_PID=$!
sleep 2

# Create 2 more tabs for Window 4
for ((i=1; i<3; i++)); do
    konsole --profile "aimgr" &
    sleep 0.2
done

# Wait for all windows to appear
sleep 5

# Get all Konsole windows
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

# We should have 16 windows total (8 + 3 + 3 + 3), but they're separate windows
# Let's group them and position them correctly

# Window 1 - First 8 windows (regular user)
echo "Positioning Window 1 (first 8 windows)..."
for ((i=0; i<8 && i<${#ALL_WINDOW_IDS[@]}; i++)); do
    if [ $i -eq 0 ]; then
        # Main window - full size
        xdotool windowmove "${ALL_WINDOW_IDS[$i]}" $WINDOW1_X $WINDOW_START_Y
        xdotool windowsize "${ALL_WINDOW_IDS[$i]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    else
        # Additional tabs - move them into the main window by closing and recreating
        xdotool windowclose "${ALL_WINDOW_IDS[$i]}"
    fi
done

# Window 2 - Next 3 windows (aimgr)
echo "Positioning Window 2 (next 3 windows)..."
for ((i=8; i<11 && i<${#ALL_WINDOW_IDS[@]}; i++)); do
    if [ $i -eq 8 ]; then
        # Main window - full size
        xdotool windowmove "${ALL_WINDOW_IDS[$i]}" $WINDOW2_X $WINDOW_START_Y
        xdotool windowsize "${ALL_WINDOW_IDS[$i]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    else
        # Additional tabs - close for now (we'll recreate them properly)
        xdotool windowclose "${ALL_WINDOW_IDS[$i]}"
    fi
done

# Window 3 - Next 3 windows (aimgr)
echo "Positioning Window 3 (next 3 windows)..."
for ((i=11; i<14 && i<${#ALL_WINDOW_IDS[@]}; i++)); do
    if [ $i -eq 11 ]; then
        # Main window - full size
        xdotool windowmove "${ALL_WINDOW_IDS[$i]}" $WINDOW3_X $WINDOW_START_Y
        xdotool windowsize "${ALL_WINDOW_IDS[$i]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    else
        # Additional tabs - close for now
        xdotool windowclose "${ALL_WINDOW_IDS[$i]}"
    fi
done

# Window 4 - Next 3 windows (aimgr)
echo "Positioning Window 4 (next 3 windows)..."
for ((i=14; i<17 && i<${#ALL_WINDOW_IDS[@]}; i++)); do
    if [ $i -eq 14 ]; then
        # Main window - full size
        xdotool windowmove "${ALL_WINDOW_IDS[$i]}" $WINDOW4_X $WINDOW_START_Y
        xdotool windowsize "${ALL_WINDOW_IDS[$i]}" $WINDOW_WIDTH $WINDOW_HEIGHT
    else
        # Additional tabs - close for now
        xdotool windowclose "${ALL_WINDOW_IDS[$i]}"
    fi
done

# Wait for windows to stabilize
sleep 2

# Now create tabs properly within each window
echo "Creating tabs within each window..."

# Get the remaining window IDs (should be 4 main windows)
REMAINING_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Remaining windows after cleanup: ${#REMAINING_IDS[@]}"

if [ ${#REMAINING_IDS[@]} -eq 4 ]; then
    # Window 1: Add 7 tabs
    xdotool windowactivate "${REMAINING_IDS[0]}"
    sleep 0.5
    for ((i=1; i<8; i++)); do
        xdotool key --delay 150 ctrl+shift+t
        sleep 0.3
    done
    
    # Window 2: Add 2 tabs
    xdotool windowactivate "${REMAINING_IDS[1]}"
    sleep 0.5
    for ((i=1; i<3; i++)); do
        xdotool key --delay 150 ctrl+shift+t
        sleep 0.3
    done
    
    # Window 3: Add 2 tabs
    xdotool windowactivate "${REMAINING_IDS[2]}"
    sleep 0.5
    for ((i=1; i<3; i++)); do
        xdotool key --delay 150 ctrl+shift+t
        sleep 0.3
    done
    
    # Window 4: Add 2 tabs
    xdotool windowactivate "${REMAINING_IDS[3]}"
    sleep 0.5
    for ((i=1; i<3; i++)); do
        xdotool key --delay 150 ctrl+shift+t
        sleep 0.3
    done
    
    echo "Successfully created all tabs!"
else
    echo "Error: Expected 4 main windows, found ${#REMAINING_IDS[@]}"
fi

echo "4 Konsole windows with custom tab configurations added successfully!"
echo "Window 1: Regular user, 8 tabs"
echo "Window 2-4: aimgr user, 3 tabs each"
