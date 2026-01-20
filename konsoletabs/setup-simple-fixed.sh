#!/bin/bash
# Simple fixed version - all aimgr tabs already aimgr, just navigate

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

# Window 1: Regular user tabs
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1
for ((i=1; i<8; i++)); do xdotool key ctrl+shift+t; sleep 0.3; done

# Set regular user directories
xdotool windowactivate "${WINDOW_IDS[0]}"
sleep 1

xdotool key ctrl+Page_Up; sleep 0.2; xdotool type " cd /home/user"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/.config/goose"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/git"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/git"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/git/ai/aiai/wsp"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/git/ai/aiai/wsp"; xdotool key Return; sleep 0.3
xdotool key ctrl+Page_Down; sleep 0.2; xdotool type " cd /home/user/git/ai/aiai/wsp"; xdotool key Return; sleep 0.3
xdotool key ctrl+Home

# Windows 2-4: All tabs already aimgr, just navigate to agent3
for window_num in 1 2 3; do
    xdotool windowactivate "${WINDOW_IDS[$window_num]}"
    sleep 1
    
    # First tab - already in avoli, navigate to agent3
    xdotool type " cd ./agent3"
    xdotool key Return
    sleep 0.5
    xdotool type " sv2"
    xdotool key Return
    sleep 0.5
    
    # Additional tabs - copy first tab to get agent3 directory
    for ((i=1; i<3; i++)); do
        xdotool key ctrl+shift+t
        sleep 1
        xdotool type " cd /home/aimgr/dev/avoli/agent3"
        xdotool key Return
        sleep 0.5
        xdotool type " sv2"
        xdotool key Return
        sleep 0.5
    done
done

echo "Success! All tabs properly configured"
xdotool windowactivate "${WINDOW_IDS[0]}"
