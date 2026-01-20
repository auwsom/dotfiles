#!/bin/bash
# Set VM resolution only if not already set to 3840x2050

CURRENT_MODE=$(xrandr | grep "connected primary" | awk '{print $3}' | cut -d'+' -f1)

if [ "$CURRENT_MODE" = "3840x2050_60.00" ] || [ "$CURRENT_MODE" = "3840x2050" ]; then
    echo "Resolution already set to $CURRENT_MODE - skipping"
    exit 0
fi

echo "Current resolution: $CURRENT_MODE, setting to 3840x2050"

# Add custom mode if it doesn't exist
if ! xrandr | grep -q "3840x2050_60.00"; then
    echo "Adding custom resolution 3840x2050_60.00"
    xrandr --newmode "3840x2050_60.00"  674.50  3840 4152 4568 5296  2050 2053 2063 2124 -hsync +vsync
    xrandr --addmode Virtual-1 "3840x2050_60.00"
fi

# Set the resolution
xrandr --output Virtual-1 --mode "3840x2050_60.00"

echo "Resolution set to 3840x2050 successfully!"
