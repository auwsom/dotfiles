#!/bin/bash
# Minimal working Konsole setup

echo "=== Konsole Setup Debug ==="

# Check basic environment
echo "Display: $DISPLAY"
echo "User: $(whoami)"
echo "Home: $HOME"

# Check if Konsole is available
echo "Konsole location: $(which konsole)"
echo "Konsole version: $(konsole --version 2>/dev/null || echo 'Version check failed')"

# Check profiles
echo "Available profiles:"
ls -la ~/.local/share/konsole/*.profile 2>/dev/null || echo "No profiles found"

# Try to start one Konsole without profile
echo "Starting basic Konsole..."
timeout 5s konsole 2>&1 &
KONSOLE_PID=$!
echo "Konsole PID: $KONSOLE_PID"

sleep 2

# Check if it started
if ps -p $KONSOLE_PID > /dev/null; then
    echo "Konsole is running (PID: $KONSOLE_PID)"
else
    echo "Konsole failed to start"
fi

# Check for windows
WINDOWS=$(xdotool search --class "konsole" 2>/dev/null | wc -l)
echo "Konsole windows found: $WINDOWS"

if [ $WINDOWS -gt 0 ]; then
    echo "Window IDs: $(xdotool search --class "konsole" 2>/dev/null)"
fi

echo "=== Debug complete ==="
