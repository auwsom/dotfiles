#!/bin/bash
# Set display resolution to 3840x2050

echo "=== Set Display Resolution to 3840x2050 ==="
echo ""

# Get current display output
DISPLAY_OUTPUT=$(xrandr | grep " connected" | head -1 | cut -d' ' -f1)
echo "Detected display: $DISPLAY_OUTPUT"

# Check if 3840x2050 mode exists
if ! xrandr | grep "$DISPLAY_OUTPUT" | grep -q "3840x2050"; then
    echo "Creating 3840x2050 mode..."
    # Generate modeline
    MODELINE=$(cvt 3840 2050 60 | tail -1 | cut -d' ' -f2-)
    
    # Add the new mode
    sudo xrandr --newmode $MODELINE
    sudo xrandr --addmode "$DISPLAY_OUTPUT" 3840x2050_60.00
    echo "✅ Mode created and added"
else
    echo "3840x2050 mode already exists"
fi

# Set the resolution
echo "Setting resolution to 3840x2050..."
xrandr --output "$DISPLAY_OUTPUT" --mode 3840x2050_60.00

if [ $? -eq 0 ]; then
    echo "✅ Resolution set to 3840x2050 successfully!"
else
    echo "❌ Failed to set resolution. Trying with sudo..."
    sudo xrandr --output "$DISPLAY_OUTPUT" --mode 3840x2050_60.00
    
    if [ $? -eq 0 ]; then
        echo "✅ Resolution set with sudo!"
    else
        echo "❌ Could not set resolution"
    fi
fi

echo ""
echo "Current display settings:"
xrandr | grep -A1 "$DISPLAY_OUTPUT" | grep -v "connected"

echo ""
echo "Press Enter to close this window..."
read input
