#!/bin/bash
# Set VM display resolution to 3840x2000 to fit in host window without scrollbar

# Add custom mode if it doesn't exist
if ! xrandr | grep -q "3840x2000_60.00"; then
    echo "Adding custom resolution 3840x2000_60.00"
    xrandr --newmode "3840x2000_60.00"  658.00  3840 4152 4568 5296  2000 2003 2013 2072 -hsync +vsync
    xrandr --addmode Virtual-1 "3840x2000_60.00"
fi

# Set the resolution
echo "Setting resolution to 3840x2050"
xrandr --output Virtual-1 --mode "3840x2050_60.00"

echo "Resolution set successfully!"
