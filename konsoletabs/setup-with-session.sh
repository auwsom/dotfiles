#!/bin/bash
# Enhanced Konsole setup with session saving support
# Creates 4 windows with proper positioning and tab creation
# Window 1: Regular user, 8 tabs
# Windows 2-4: aimgr user, 3 tabs each
# Now with directory remembering

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_FILE="$HOME/.config/konsole-session-latest.json"

# Configuration - RESTORED TO ORIGINAL OVERLAPPING LAYOUT
TOTAL_WINDOWS=4
WINDOW_WIDTH=1200
WINDOW_HEIGHT=1940
START_X=0
START_Y=97

echo "Enhanced Konsole setup with session support..."

# Check if we should restore from session
if [ "$1" = "--restore" ] && [ -f "$SESSION_FILE" ]; then
    echo "Restoring from saved session..."
    "$SCRIPT_DIR/restore-session-auto.sh"
    exit 0
fi

# Function to create a window with tabs
create_window() {
    local window_num=$1
    local profile=$2
    local tab_count=$3
    local x_offset=$4
    
    echo "Creating Window $window_num with $tab_count tabs using profile: $profile"
    
    # Launch Konsole with specified profile
    if [ "$profile" = "Regular User" ]; then
        konsole --profile "$profile" &
    else
        konsole --profile "$profile" &
    fi
    
    # Wait for window to appear
    sleep 1.5
    
    # Get the window ID of the most recent Konsole window
    local window_id=$(xdotool search --class "konsole" | tail -1)
    
    if [ -z "$window_id" ]; then
        echo "Error: Could not find Konsole window"
        return 1
    fi
    
    # Position the window
    xdotool windowmove "$window_id" $x_offset $START_Y
    xdotool windowsize "$window_id" $WINDOW_WIDTH $WINDOW_HEIGHT
    
    # Focus the window
    xdotool windowfocus "$window_id"
    sleep 0.5
    
    # Create additional tabs
    for ((tab=2; tab<=tab_count; tab++)); do
        echo "Creating tab $tab in window $window_num"
        xdotool key --window "$window_id" Ctrl+Shift+T
        sleep 0.7
        
        # If aimgr profile, type the commands to switch user
        if [ "$profile" = "aimgr" ]; then
            xdotool type --window "$window_id" "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
            xdotool key --window "$window_id" Return
            sleep 1.5
        fi
    done
    
    # For the first tab in aimgr windows, also execute the user switch
    if [ "$profile" = "aimgr" ]; then
        xdotool type --window "$window_id" "sudo -u aimgr bash -c 'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash'"
        xdotool key --window "$window_id" Return
        sleep 1.5
    fi
    
    echo "Window $window_num created successfully"
}

# Create Window 1 (Regular User)
create_window 1 "Regular User" 8 $START_X

# Create Windows 2-4 (aimgr user) - OVERLAPPING LAYOUT
for ((i=2; i<=TOTAL_WINDOWS; i++)); do
    x_offset=$((START_X + (i-2) * 320))  # 320px offset for overlap (1200-320=880 visible)
    create_window $i "aimgr" 3 $x_offset
done

echo "Setup complete!"
echo ""
echo "Session management commands:"
echo "  Save current session: $SCRIPT_DIR/save-session-auto.sh"
echo "  Restore session: $SCRIPT_DIR/setup-with-session.sh --restore"
echo ""
echo "The session will remember working directories and window positions."
