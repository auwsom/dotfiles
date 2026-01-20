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
    if sudo xrandr --newmode $MODELINE 2>/dev/null; then
        echo "✅ Mode created successfully"
        if sudo xrandr --addmode "$DISPLAY_OUTPUT" 3840x2050_60.00 2>/dev/null; then
            echo "✅ Mode added to display"
        else
            echo "❌ Failed to add mode"
        fi
    else
        echo "❌ Failed to create mode"
        echo "Mode might already exist but with different name"
    fi
else
    echo "3840x2050 mode already exists"
fi

# Try to find the correct mode name
MODE_NAME=$(xrandr | grep -E "3840.*2050" | grep -v "connected" | awk '{print $1}' | head -1)

if [ -n "$MODE_NAME" ]; then
    echo "Found compatible mode: $MODE_NAME"
    echo "Setting resolution to $MODE_NAME..."
    
    if xrandr --output "$DISPLAY_OUTPUT" --mode "$MODE_NAME" 2>/dev/null; then
        echo "✅ Resolution set to $MODE_NAME successfully!"
    else
        echo "❌ Failed to set resolution. Trying with sudo..."
        if sudo xrandr --output "$DISPLAY_OUTPUT" --mode "$MODE_NAME" 2>/dev/null; then
            echo "✅ Resolution set with sudo!"
        else
            echo "❌ Could not set resolution. Mode may not be available."
        fi
    fi
else
    echo "❌ No 3840x2050 compatible mode found"
    echo "Available modes for $DISPLAY_OUTPUT:"
    xrandr | grep -A20 "$DISPLAY_OUTPUT" | grep -E "^\s+[0-9]" | head -10
fi

echo ""
echo "Current display settings:"
xrandr | grep -A1 "$DISPLAY_OUTPUT" | grep -v "connected"

echo ""
echo "Press Enter to close this window..."
read input
