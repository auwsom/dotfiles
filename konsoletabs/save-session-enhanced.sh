#!/bin/bash
# Enhanced session saver that properly detects su sessions and working directories

SESSION_FILE="$HOME/.config/konsole-session-$(date +%Y%m%d-%H%M%S).json"

echo "Enhanced Konsole session saver - detecting su sessions and CWDs..."

cat > "$SESSION_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "version": "2.0",
  "windows": [
EOF

FIRST_WINDOW=true

# Get all Konsole window IDs
KONSOLE_WINDOWS=$(xdotool search --class "konsole" 2>/dev/null)

for window_id in $KONSOLE_WINDOWS; do
    # Get window geometry
    eval $(xdotool getwindowgeometry --shell "$window_id" 2>/dev/null)
    WINDOW_TITLE=$(xdotool getwindowname "$window_id" 2>/dev/null)
    
    # Get the process PID for this window
    window_pid=$(xdotool getwindowpid "$window_id" 2>/dev/null)
    
    if [ -n "$window_pid" ]; then
        # Get all bash processes in this window's process tree
        session_pids=$(pgrep -f "bash" | grep -v "$$" | head -10)
        
        # For each session/tab in this window
        for session_pid in $session_pids; do
            if [ -d "/proc/$session_pid" ]; then
                # Get working directory
                CWD="$HOME"  # default
                if [ -r "/proc/$session_pid/cwd" ]; then
                    CWD=$(readlink "/proc/$session_pid/cwd" 2>/dev/null)
                elif sudo test -r "/proc/$session_pid/cwd" 2>/dev/null; then
                    CWD=$(sudo readlink "/proc/$session_pid/cwd" 2>/dev/null)
                fi
                
                # Get command line
                CMDLINE=$(cat "/proc/$session_pid/cmdline" 2>/dev/null | tr '\0' ' ' | head -c200)
                
                # Get process status to check for su sessions
                STATUS=$(cat "/proc/$session_pid/status" 2>/dev/null | grep "^Uid:" | awk '{print $2,$3}')
                
                # Check if this is an aimgr session by various methods
                profile="regular"
                effective_user="user"
                
                # Method 1: Check if process is running as aimgr user
                if echo "$STATUS" | grep -q "1001"; then  # aimgr UID is typically 1001
                    profile="aimgr"
                    effective_user="aimgr"
                fi
                
                # Method 2: Check process parentage for su commands
                parent_pid=$(grep "^PPid:" "/proc/$session_pid/status" 2>/dev/null | awk '{print $2}')
                if [ -n "$parent_pid" ] && [ -d "/proc/$parent_pid" ]; then
                    parent_cmdline=$(cat "/proc/$parent_pid/cmdline" 2>/dev/null | tr '\0' ' ')
                    if [[ "$parent_cmdline" == *"su aimgr"* ]] || [[ "$parent_cmdline" == *"sudo -u aimgr"* ]]; then
                        profile="aimgr"
                        effective_user="aimgr"
                    fi
                fi
                
                # Method 3: Check if we're in an avoli directory
                if [[ "$CWD" == *"/avoli"* ]] || [[ "$WINDOW_TITLE" == *"aimgr"* ]]; then
                    profile="aimgr"
                    effective_user="aimgr"
                fi
                
                # Method 4: Check all processes in the system for su aimgr
                if ! ps aux | grep -E "su aimgr|sudo.*aimgr" | grep -v grep | grep -q "$session_pid"; then
                    # Check if this bash process is a child of a su process
                    su_pids=$(pgrep -f "su aimgr" 2>/dev/null)
                    for su_pid in $su_pids; do
                        if pstree -p "$su_pid" 2>/dev/null | grep -q "$session_pid"; then
                            profile="aimgr"
                            effective_user="aimgr"
                            break
                        fi
                    done
                fi
                
                # Determine profile name
                if [ "$profile" = "aimgr" ]; then
                    profile_name="aimgr"
                else
                    profile_name="Regular User"
                fi
                
                # Add comma for all but first window
                if [ "$FIRST_WINDOW" = false ]; then
                    echo "," >> "$SESSION_FILE"
                fi
                
                # Escape quotes in strings for JSON
                ESCAPED_TITLE=$(echo "$WINDOW_TITLE" | sed 's/"/\\"/g')
                ESCAPED_CMDLINE=$(echo "$CMDLINE" | sed 's/"/\\"/g')
                
                # Add session to JSON
                cat >> "$SESSION_FILE" << EOF
    {
      "session_id": "pid_$session_pid",
      "window_id": "$window_id",
      "x": $X,
      "y": $Y,
      "width": $WIDTH,
      "height": $HEIGHT,
      "profile": "$profile",
      "effective_user": "$effective_user",
      "title": "$ESCAPED_TITLE",
      "working_directory": "$CWD",
      "profile_name": "$profile_name",
      "cmdline": "$ESCAPED_CMDLINE"
EOF
                
                echo "    }" >> "$SESSION_FILE"
                FIRST_WINDOW=false
                
                # Debug output
                if [ "$profile" = "aimgr" ]; then
                    echo "🎯 Detected AIMGR session: PID $session_pid, CWD: $CWD, Parent: $parent_pid"
                fi
            fi
        done
    fi
done

echo "  ]" >> "$SESSION_FILE"
echo "}" >> "$SESSION_FILE"

# Create symlink to latest
ln -sf "$SESSION_FILE" "$HOME/.config/konsole-session-latest.json"

echo "Enhanced session saved to $SESSION_FILE"
echo "Latest session: $HOME/.config/konsole-session-latest.json"

# Show summary
python3 << EOF
import json
import os

session_file = os.path.expanduser("~/.config/konsole-session-latest.json")
try:
    with open(session_file, 'r') as f:
        session = json.load(f)
    
    print(f"\n📊 Enhanced Session Summary:")
    print(f"   Timestamp: {session['timestamp']}")
    print(f"   Windows/Sessions: {len(session['windows'])}")
    
    regular_count = 0
    aimgr_count = 0
    unique_cwds = set()
    
    for window in session['windows']:
        if window['profile'] == 'aimgr':
            aimgr_count += 1
            print(f"   🎯 AIMGR: {window['working_directory']} (user: {window.get('effective_user', 'unknown')})")
        else:
            regular_count += 1
        
        unique_cwds.add(window['working_directory'])
    
    print(f"\n📈 Statistics:")
    print(f"   Regular sessions: {regular_count}")
    print(f"   AIMGR sessions: {aimgr_count}")
    print(f"   Unique working directories: {len(unique_cwds)}")
    print(f"   Coverage: {'✅' if aimgr_count > 0 else '❌ No AIMGR sessions detected'}")
        
except Exception as e:
    print(f"❌ Could not parse session file: {e}")
EOF
