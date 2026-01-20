#!/bin/bash
# Set VM display resolution to best available for Konsole windows

echo "Setting optimal display resolution..."

# Get the connected display
DISPLAY_OUTPUT=$(xrandr | grep " connected" | head -1 | cut -d' ' -f1)

# Try to set to 3840x2160 (4K) which should be available
if xrandr | grep "$DISPLAY_OUTPUT" | grep -q "3840x2160"; then
    echo "Setting resolution to 3840x2160..."
    xrandr --output "$DISPLAY_OUTPUT" --mode 3840x2160
    echo "✅ Display resolution set to 3840x2160"
else
    echo "3840x2160 not available, using current resolution"
fi

# Verify the change
echo "Current display resolution:"
xrandr | grep " connected" | grep -E "[0-9]+x[0-9]+"

# Update Konsole window calculations for 3840x2160
echo ""
echo "For 3840x2160 display, your Konsole windows should be:"
echo "- Width: 960px each (4 windows x 960 = 3840px)"
echo "- Height: 2050px (leaving room for panels)"
echo "- Positions: 0, 960, 1920, 2880 pixels from left"
