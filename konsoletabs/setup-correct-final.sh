#!/bin/bash
# Correct version - sudo for aimgr switching, proper directory navigation

echo "Setting up 4 Konsole windows..."

# Screen setup
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050
WINDOW_HEIGHT=$SCREEN_HEIGHT
WINDOW_WIDTH=1200
WINDOW_START_Y=0
WINDOW4_X=$((SCREEN_WIDTH - WINDOW_WIDTH))
SPACING=$((WINDOW4_X / 3))

# Start windows
konsole --profile "Regular User" &
sleep 3
konsole --profile "aimgr" &
sleep 2
konsole --profile "aimgr" &
sleep 2
konsole --profile "aimgr" &
sleep 3

# Wait for windows to initialize
sleep 2

# Get and position windows
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")

# Position windows
xdotool windowmove "${WINDOW_IDS[0]}" 0 $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW_WIDTH $WINDOW_HEIGHT
xdotool windowmove "${WINDOW_IDS[1]}" $SPACING $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW_WIDTH $WINDOW_HEIGHT
xdotool windowmove "${WINDOW_IDS[2]}" $((SPACING * 2)) $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW_WIDTH $WINDOW_HEIGHT
xdotool windowmove "${WINDOW_IDS[3]}" $((SPACING * 3)) $WINDOW_START_Y
xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW_WIDTH $WINDOW_HEIGHT

sleep 2

# Window 1: Regular user tabs - create and set directory for each immediately
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1

# Create tabs and set directories immediately (more reliable)
for tab_num in {1..8}; do
    # Set directory based on tab number
    case $tab_num in
        1|2) directory="/home/user" ;;
        3) directory="/home/user/.config/goose" ;;
        4|5) directory="/home/user/git" ;;
        6|7|8) directory="/home/user/git/ai/aiai/wsp" ;;
    esac
    
    # If this is not the first tab, create it
    if [ $tab_num -gt 1 ]; then
        xdotool key ctrl+shift+t
        sleep 0.5
    fi
    
    # Set directory in this tab
    xdotool type " cd $directory"
    xdotool key Return
    sleep 0.3
    
    # Go to next tab position
    if [ $tab_num -lt 8 ]; then
        xdotool key ctrl+Page_Down
        sleep 0.2
    fi
done

# Return to first tab
xdotool key ctrl+Home
sleep 0.5

# Windows 2-4: Fix first tab to be in agent3, use sudo for additional tabs
for window_num in 1 2 3; do
    xdotool windowactivate "${WINDOW_IDS[$window_num]}"
    sleep 1
    
    # First tab - already in avoli, navigate to agent3 with sv2
    xdotool type " cd ./agent3"
    xdotool key Return
    sleep 0.5
    xdotool type " sv2"
    xdotool key Return
    sleep 0.5
    
    # Additional tabs - use sudo to switch to aimgr
    for ((i=1; i<3; i++)); do
        xdotool key ctrl+shift+t
        sleep 1
        
        # Switch to aimgr using sudo and navigate to agent3
        xdotool type " sudo -u aimgr bash -c 'cd /home/aimgr/dev/avoli/agent3 && exec bash'"
        xdotool key Return
        sleep 1
        xdotool type " sv2"
        xdotool key Return
        sleep 0.5
    done
done

echo "Success! First tabs in agent3, additional tabs use sudo"
xdotool windowactivate "${WINDOW_IDS[0]}"
