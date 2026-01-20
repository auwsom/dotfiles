#!/bin/bash
# Add 4 Konsole windows with custom proportions for 3840x2050 screen

# Screen dimensions - updated for VM
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050

# Layout configuration - custom proportions
# Wider windows on sides, narrower in middle
WINDOW_HEIGHT=$((SCREEN_HEIGHT - 97))  # Account for Y position start
WINDOW1_WIDTH=1200  # Left side - moderate
WINDOW2_WIDTH=800   # Middle-left - narrower  
WINDOW3_WIDTH=800   # Middle-right - narrower
WINDOW4_WIDTH=1200  # Right side - moderate

# Calculate positions to fill width exactly
WINDOW_START_Y=97
WINDOW1_X=0
WINDOW2_X=$WINDOW1_WIDTH
WINDOW3_X=$((WINDOW2_X + WINDOW2_WIDTH))
WINDOW4_X=$((WINDOW3_X + WINDOW3_WIDTH))

# Verify total width
TOTAL_WIDTH=$((WINDOW1_WIDTH + WINDOW2_WIDTH + WINDOW3_WIDTH + WINDOW4_WIDTH))

echo "Adding 4 Konsole windows with custom proportions..."
echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"
echo "Window 1: ${WINDOW1_WIDTH}x${WINDOW_HEIGHT} at ($WINDOW1_X,$WINDOW_START_Y)"
echo "Window 2: ${WINDOW2_WIDTH}x${WINDOW_HEIGHT} at ($WINDOW2_X,$WINDOW_START_Y)" 
echo "Window 3: ${WINDOW3_WIDTH}x${WINDOW_HEIGHT} at ($WINDOW3_X,$WINDOW_START_Y)"
echo "Window 4: ${WINDOW4_WIDTH}x${WINDOW_HEIGHT} at ($WINDOW4_X,$WINDOW_START_Y)"
echo "Total width used: ${TOTAL_WIDTH}px (screen: ${SCREEN_WIDTH}px)"

# Start 4 new Konsole windows with larger font profile
echo "Starting 4 new Konsole windows with larger font..."
konsole --profile "Large Font" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "Large Font" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "Large Font" --layout "$HOME/konsole_layout1.json" &
sleep 0.5
konsole --profile "Large Font" --layout "$HOME/konsole_layout1.json" &

# Wait for windows to appear
sleep 3

# Get all Konsole windows
echo "Getting window IDs..."
ALL_WINDOW_IDS=($(xdotool search --class "konsole" 2>/dev/null))
echo "Total Konsole windows found: ${#ALL_WINDOW_IDS[@]}"

# Take the last 4 (newest) windows
WINDOW_IDS=("${ALL_WINDOW_IDS[@]: -4}")

echo "Positioning newest 4 windows: ${WINDOW_IDS[@]}"

if [ ${#WINDOW_IDS[@]} -ge 4 ]; then
    # Window 1 - Left side (moderate width)
    xdotool windowmove "${WINDOW_IDS[0]}" $WINDOW1_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[0]}" $WINDOW1_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[0]} at ($WINDOW1_X,$WINDOW_START_Y) size ${WINDOW1_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 2 - Middle-left (narrower)
    xdotool windowmove "${WINDOW_IDS[1]}" $WINDOW2_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[1]}" $WINDOW2_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[1]} at ($WINDOW2_X,$WINDOW_START_Y) size ${WINDOW2_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 3 - Middle-right (narrower)
    xdotool windowmove "${WINDOW_IDS[2]}" $WINDOW3_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[2]}" $WINDOW3_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[2]} at ($WINDOW3_X,$WINDOW_START_Y) size ${WINDOW3_WIDTH}x${WINDOW_HEIGHT}"
    
    # Window 4 - Right side (moderate width)
    xdotool windowmove "${WINDOW_IDS[3]}" $WINDOW4_X $WINDOW_START_Y
    xdotool windowsize "${WINDOW_IDS[3]}" $WINDOW4_WIDTH $WINDOW_HEIGHT
    echo "Positioned window ${WINDOW_IDS[3]} at ($WINDOW4_X,$WINDOW_START_Y) size ${WINDOW4_WIDTH}x${WINDOW_HEIGHT}"
    
    echo "Successfully positioned all 4 Konsole windows!"
    
    # Activate the first window
    xdotool windowactivate "${WINDOW_IDS[0]}"
    
else
    echo "Error: Expected at least 4 Konsole windows, found ${#WINDOW_IDS[@]}"
    exit 1
fi

echo "4 custom proportional Konsole windows added successfully!"
