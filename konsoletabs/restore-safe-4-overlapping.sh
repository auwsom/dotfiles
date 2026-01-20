#!/bin/bash
# Safe restore of 4 overlapping Konsole windows (preserves current session)

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2160

# Layout configuration
TITLEBAR_OFFSET=40
WINDOW_WIDTH=1400
WINDOW_HEIGHT=2000
WINDOW_START_Y=$TITLEBAR_OFFSET

# Calculate positions for 4 overlapping windows
# Each window overlaps by about 25% with the next
OVERLAP_OFFSET=$((WINDOW_WIDTH / 4))  # 350 pixels overlap
WINDOW1_X=0
WINDOW2_X=$OVERLAP_OFFSET
WINDOW3_X=$((OVERLAP_OFFSET * 2))
WINDOW4_X=$((OVERLAP_OFFSET * 3))

echo "Restoring 4 overlapping Konsole windows (SAFE MODE)..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Each window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"
echo "Overlap offset: ${OVERLAP_OFFSET}px"

# Get current terminal's PID to avoid killing it
CURRENT_PID=$$
echo "Current session PID: $CURRENT_PID (will be preserved)"

# Get all Konsole processes
KONSOLE_PIDS=$(pgrep -f "konsole")
echo "All Konsole PIDs: $KONSOLE_PIDS"

# Find PIDs that are NOT our current session
SAFE_TO_KILL=""
for pid in $KONSOLE_PIDS; do
    # Check if this PID is related to our current session
    if ! pstree -p $pid | grep -q $CURRENT_PID; then
        SAFE_TO_KILL="$SAFE_TO_KILL $pid"
    else
        echo "Preserving Konsole PID $pid (contains current session)"
    fi
done

if [ -n "$SAFE_TO_KILL" ]; then
    echo "Closing other Konsole windows: $SAFE_TO_KILL"
    echo $SAFE_TO_KILL | xargs kill && sleep 2
else
    echo "No other Konsole windows to close"
fi

# Wait for processes to terminate
sleep 1

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

# Get the newest 4 window IDs (excluding current window)
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))

# Try to identify and exclude the current window
CURRENT_WINDOW_ID=""
for wid in "${ALL_WINDOW_IDS[@]}"; do
    # Get the PID of the window
    WINDOW_PID=$(xprop -id $wid | grep "_NET_WM_PID" | awk '{print $3}')
    if [ "$WINDOW_PID" = "$CURRENT_PID" ] || pstree -p $WINDOW_PID | grep -q $CURRENT_PID; then
        CURRENT_WINDOW_ID=$wid
        echo "Found current window: $wid (PID: $WINDOW_PID)"
        break
    fi
done

# Filter out current window and get the 4 newest
NEW_WINDOW_IDS=()
for wid in "${ALL_WINDOW_IDS[@]}"; do
    if [ "$wid" != "$CURRENT_WINDOW_ID" ]; then
        NEW_WINDOW_IDS+=($wid)
    fi
done

# Take the last 4 (newest) windows
WINDOW_IDS=("${NEW_WINDOW_IDS[@]: -4}")

echo "Found ${#WINDOW_IDS[@]} new windows to position: ${WINDOW_IDS[@]}"

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
    echo "Error: Expected at least 4 new Konsole windows, found ${#WINDOW_IDS[@]}"
    echo "Available new windows: ${NEW_WINDOW_IDS[@]}"
    exit 1
fi

echo "Safe Konsole 4-window overlapping layout restoration complete!"
