#!/bin/bash
# Save current 3-window Konsole layout (fixed version)

SAVE_FILE="$HOME/.config/konsole-3-window-layout.txt"

echo "Saving current Konsole window layout..."

# Get all Konsole windows
WINDOW_IDS=($(xdotool search --class "konsole"))

if [ ${#WINDOW_IDS[@]} -eq 0 ]; then
    echo "No Konsole windows found!"
    exit 1
fi

echo "# Konsole window layout saved on $(date)" > "$SAVE_FILE"
echo "# Format: Window_ID X Y Width Height" >> "$SAVE_FILE"
echo "" >> "$SAVE_FILE"

# Save window geometry for each window
for WID in "${WINDOW_IDS[@]}"; do
    # Get window geometry using xwininfo for more reliable parsing
    X=$(xwininfo -id $WID | grep "Absolute upper-left X:" | awk '{print $4}')
    Y=$(xwininfo -id $WID | grep "Absolute upper-left Y:" | awk '{print $4}')
    WIDTH=$(xwininfo -id $WID | grep "Width:" | awk '{print $2}')
    HEIGHT=$(xwininfo -id $WID | grep "Height:" | awk '{print $2}')
    
    echo "$WID $X $Y $WIDTH $HEIGHT" >> "$SAVE_FILE"
done

echo "" >> "$SAVE_FILE"
echo "# Large windows (likely your main 3):" >> "$SAVE_FILE"
echo "" >> "$SAVE_FILE"

# Show large windows (likely your main 3)
while read WID X Y WIDTH HEIGHT; do
    if [ "$WIDTH" -gt 1000 ] && [ "$HEIGHT" -gt 1000 ]; then
        echo "Large window: $WID at ($X,$Y) size ${WIDTH}x${HEIGHT}" >> "$SAVE_FILE"
    fi
done < "$SAVE_FILE"

echo "Layout saved to: $SAVE_FILE"
echo "All windows:"
cat "$SAVE_FILE"
