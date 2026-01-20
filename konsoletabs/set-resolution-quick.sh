#!/bin/bash
# Set display resolution to 3840x2050 (fixed version)

echo "=== Set Display Resolution to 3840x2050 ==="
echo ""

# Get current display
DISPLAY_OUTPUT="Virtual-1"
echo "Setting display: $DISPLAY_OUTPUT"

# Try to set the resolution using the modeline we already created
echo "Setting resolution to 3840x2050..."

# Use the exact modeline from our previous setup
sudo xrandr --newmode "3840x2050_60.00"  674.50  3840 4152 4568 5296  2050 2053 2063 2124 -hsync +vsync
sudo xrandr --addmode Virtual-1 "3840x2050_60.00"
sudo xrandr --output Virtual-1 --mode "3840x2050_60.00"

if [ $? -eq 0 ]; then
    echo "✅ Resolution set to 3840x2050 successfully!"
else
    echo "❌ Could not set resolution"
    echo "Current resolution: $(xrandr | grep -A1 "$DISPLAY_OUTPUT" | grep -v connected | awk '{print $1}')"
fi

echo ""
echo "Current display settings:"
xrandr | grep -A2 "$DISPLAY_OUTPUT"

echo ""
echo "Press Enter to close..."
read input
