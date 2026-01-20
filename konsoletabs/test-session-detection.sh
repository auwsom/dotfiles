#!/bin/bash
# Test script to verify session detection capabilities

echo "🧪 Testing Konsole Session Detection"
echo "=================================="

# Test 1: Current Konsole processes
echo -e "\n📊 Test 1: Current Konsole Processes"
echo "-------------------------------------"
echo "Running Konsole processes:"
pgrep -f "konsole" | while read pid; do
    if [ -d "/proc/$pid" ]; then
        echo "  PID $pid:"
        echo "    Command: $(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ' | cut -c1-80)"
        echo "    CWD: $(readlink "/proc/$pid/cwd" 2>/dev/null || 'unknown')"
        echo "    Children: $(pgrep -P "$pid" 2>/dev/null | wc -l)"
        echo ""
    fi
done

# Test 2: Detecting su sessions
echo -e "\n🎯 Test 2: Detecting su/aimgr sessions"
echo "----------------------------------------"
echo "Looking for processes containing 'su' or 'aimgr':"
ps aux | grep -E "(su|aimgr)" | grep -v grep | while read line; do
    echo "  $line"
done

# Test 3: Window detection
echo -e "\n🪟 Test 3: Window Detection"
echo "----------------------------"
KONSOLE_WINDOWS=$(xdotool search --class "konsole" 2>/dev/null)
echo "Found Konsole windows: $KONSOLE_WINDOWS"

for window_id in $KONSOLE_WINDOWS; do
    echo "  Window $window_id:"
    eval $(xdotool getwindowgeometry --shell "$window_id" 2>/dev/null)
    echo "    Position: ($X, $Y)"
    echo "    Size: ${WIDTH}x${HEIGHT}"
    echo "    Title: $(xdotool getwindowname "$window_id" 2>/dev/null)"
    echo "    PID: $(xdotool getwindowpid "$window_id" 2>/dev/null)"
    echo ""
done

# Test 4: Enhanced save test
echo -e "\n💾 Test 4: Enhanced Save Test"
echo "------------------------------"
echo "Running enhanced session save..."
if /home/user/git/dotfiles/konsoletabs/save-session-enhanced.sh; then
    echo "✅ Enhanced save completed successfully"
    echo "📁 Latest session: ~/.config/konsole-session-latest.json"
else
    echo "❌ Enhanced save failed"
fi

echo -e "\n🔍 Summary:"
echo "-----------"
echo "• If you have su aimgr sessions running, they should appear as 'aimgr' profile"
echo "• Working directories should show the actual CWD of each session"
echo "• Window positions should reflect your actual layout"
echo "• Use the desktop shortcut when your full layout is set up"
