#!/bin/bash
# Comprehensive Konsole session restore script

# Configuration
LAYOUT_FILE="$HOME/konsole_layout1.json"
DESIRED_WIDTH=1200
DESIRED_HEIGHT=800
DESIRED_X=100
DESIRED_Y=100

echo "Restoring Konsole session with proper layout and positioning..."

# Kill existing Konsole instances to avoid conflicts
pkill -f "konsole" && sleep 1

# Wait for processes to fully terminate
while pgrep -f "konsole" > /dev/null; do
    sleep 0.5
done

# Start Konsole with the layout
konsole --layout "$LAYOUT_FILE" &

# Wait for Konsole to start
sleep 2

# Get the Konsole window ID
KONSOLE_WID=$(xdotool search --class "konsole" | head -1)

if [ -n "$KONSOLE_WID" ]; then
    echo "Found Konsole window: $KONSOLE_WID"
    
    # Move and resize the window
    xdotool windowmove "$KONSOLE_WID" $DESIRED_X $DESIRED_Y
    xdotool windowsize "$KONSOLE_WID" $DESIRED_WIDTH $DESIRED_HEIGHT
    
    # Bring to front
    xdotool windowactivate "$KONSOLE_WID"
    
    echo "Konsole positioned at ($DESIRED_X,$DESIRED_Y) with size ${DESIRED_WIDTH}x${DESIRED_HEIGHT}"
else
    echo "Could not find Konsole window"
fi

# Optional: Open additional tabs if needed
# sleep 1
# konsole --new-tab --workdir "$HOME/ai" &
# konsole --new-tab --workdir "$HOME/projects" &

echo "Konsole session restore complete!"
