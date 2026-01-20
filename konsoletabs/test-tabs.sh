#!/bin/bash
# Simple test - create 1 window with tabs

echo "Testing basic Konsole window creation..."

# Kill existing
pkill -f "konsole" && sleep 2

# Create one window
echo "Creating one Regular User window..."
konsole --profile "Regular User" &
sleep 3

# Get window ID
WID=$(xdotool search --class "konsole" | head -1)
echo "Window ID: $WID"

if [ -n "$WID" ]; then
    echo "Activating window..."
    xdotool windowactivate "$WID"
    sleep 1
    
    echo "Creating 3 tabs..."
    for i in {1..3}; do
        echo "Creating tab $i..."
        xdotool key --delay 200 ctrl+shift+t
        sleep 1
    done
    
    echo "Done. Total windows: $(xdotool search --class "konsole" | wc -l)"
else
    echo "No window found!"
fi
