#!/bin/bash
# Complete system test for Konsole session management

echo "=== Konsole Session Management System Test ==="
echo ""

# Test 1: Display Resolution
echo "1. Testing Display Resolution..."
xdotool search --class "konsole" | while read wid; do echo -n "Window $wid: "; xdotool getwindowgeometry "$wid"; done

echo ""
echo "Current display resolution:"
xrandr | grep " connected" | grep -E "[0-9]+x[0-9]+"

# Test 2: Session Files
echo ""
echo "2. Checking Session Files..."
LATEST_SESSION="$HOME/.config/konsole-session-latest.json"
if [ -f "$LATEST_SESSION" ]; then
    echo "✅ Latest session file exists: $LATEST_SESSION"
    echo "   Timestamp: $(grep -o '"timestamp": "[^"]*"' "$LATEST_SESSION" | cut -d'"' -f4)"
    echo "   Windows: $(grep -c '"window_id"' "$LATEST_SESSION")"
else
    echo "❌ No latest session file found"
fi

# Test 3: Autosave Daemon
echo ""
echo "3. Checking Autosave Daemon..."
if [ -f "$HOME/.config/konsole-autosave.pid" ]; then
    PID=$(cat "$HOME/.config/konsole-autosave.pid")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Autosave daemon is running (PID: $PID)"
    else
        echo "❌ Autosave daemon PID file exists but process not running"
    fi
else
    echo "❌ Autosave daemon PID file not found"
fi

# Test 4: Scripts
echo ""
echo "4. Checking Script Permissions..."
SCRIPT_DIR="/home/user/git/dotfiles/konsoletabs"
for script in konsole-manager.sh autosave-control.sh force-display-resolution.sh startup-script.sh; do
    if [ -x "$SCRIPT_DIR/$script" ]; then
        echo "✅ $script is executable"
    else
        echo "❌ $script is not executable"
    fi
done

# Test 5: Desktop Integration
echo ""
echo "5. Checking Desktop Integration..."
if [ -f "$HOME/Desktop/restore-konsole.desktop" ]; then
    echo "✅ Desktop restore shortcut exists"
else
    echo "❌ Desktop restore shortcut missing"
fi

if [ -f "$HOME/.config/autostart/konsole-startup.desktop" ]; then
    echo "✅ Startup autostart entry exists"
else
    echo "❌ Startup autostart entry missing"
fi

# Test 6: Konsole Windows
echo ""
echo "6. Current Konsole Windows:"
KONSOLE_WINDOWS=$(xdotool search --class "konsole" | wc -l)
echo "   Number of Konsole windows: $KONSOLE_WINDOWS"

if [ $KONSOLE_WINDOWS -gt 0 ]; then
    echo "   Window details:"
    xdotool search --class "konsole" | while read wid; do
        GEOM=$(xdotool getwindowgeometry "$wid" | grep "Geometry")
        POS=$(xdotool getwindowgeometry "$wid" | grep "Position")
        echo "     $wid: $POS, $GEOM"
    done
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "Expected for 4-window layout:"
echo "- Display: 3840x2160"
echo "- Windows: 4 total"
echo "- Positions: 0, 960, 1920, 2880px from left"
echo "- Size: 960x2050px each"
