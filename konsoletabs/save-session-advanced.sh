#!/bin/bash
# Advanced session saver that can detect individual tab directories

SESSION_FILE="$HOME/.config/konsole-session-$(date +%Y%m%d-%H%M%S).json"

echo "Advanced Konsole session saver..."

# Use qdbus to interact with Konsole sessions
# This is a more advanced approach that can read tab information

cat > "$SESSION_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "version": "2.0",
  "windows": [
EOF

FIRST_WINDOW=true

# Get all Konsole sessions via DBus
qdbus org.kde.konsole >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # Konsole is running with DBus support
    SESSIONS=$(qdbus org.kde.konsole | grep "/Sessions/")
    
    for session_path in $SESSIONS; do
        session_num=$(echo "$session_path" | sed 's/\/Sessions\///')
        
        # Get session info
        session_title=$(qdbus org.kde.konsole "$session_path" title 2>/dev/null)
        session_profile=$(qdbus org.kde.konsole "$session_path" profile 2>/dev/null)
        
        # Try to get working directory (this might not always work)
        working_dir="$HOME"
        
        # Get window ID for this session
        window_id=""
        konsole_pids=$(pgrep -f "konsole")
        
        for pid in $konsole_pids; do
            if [ -L "/proc/$pid/cwd" ]; then
                cwd=$(readlink "/proc/$pid/cwd")
                # Check if this session matches our current working context
                # This is a heuristic - we're matching by process tree
                if [ -n "$cwd" ]; then
                    working_dir="$cwd"
                    window_id=$(xdotool search --pid "$pid" 2>/dev/null | head -1)
                    break
                fi
            fi
        done
        
        if [ -n "$window_id" ]; then
            # Get window geometry
            eval $(xdotool getwindowgeometry --shell "$window_id" 2>/dev/null)
        else
            # Default geometry
            X=0
            Y=97
            WIDTH=960
            HEIGHT=1940
        fi
        
        # Determine profile type
        if [[ "$session_title" == *"aimgr"* ]] || [[ "$working_dir" == *"avoli"* ]]; then
            profile="aimgr"
        else
            profile="regular"
        fi
        
        # Add comma for all but first window
        if [ "$FIRST_WINDOW" = false ]; then
            echo "," >> "$SESSION_FILE"
        fi
        
        # Add session to JSON
        cat >> "$SESSION_FILE" << EOF
    {
      "session_id": "$session_num",
      "window_id": "$window_id",
      "x": $X,
      "y": $Y,
      "width": $WIDTH,
      "height": $HEIGHT,
      "profile": "$profile",
      "title": "$session_title",
      "working_directory": "$working_dir",
      "profile_name": "$session_profile"
EOF
        
        echo "    }" >> "$SESSION_FILE"
        FIRST_WINDOW=false
    done
else
    # Fallback to process-based detection
    echo "DBus not available, using process-based detection..."
    
    KONSOLE_PIDS=$(pgrep -f "konsole")
    
    for pid in $KONSOLE_PIDS; do
        if [ -L "/proc/$pid/cwd" ]; then
            CWD=$(readlink "/proc/$pid/cwd")
            WINDOW_ID=$(xdotool search --pid "$pid" 2>/dev/null | head -1)
            
            if [ -n "$WINDOW_ID" ]; then
                eval $(xdotool getwindowgeometry --shell "$WINDOW_ID" 2>/dev/null)
                WINDOW_TITLE=$(xdotool getwindowname "$WINDOW_ID" 2>/dev/null)
                
                if [[ "$WINDOW_TITLE" == *"aimgr"* ]] || [[ "$CWD" == *"avoli"* ]]; then
                    profile="aimgr"
                else
                    profile="regular"
                fi
                
                if [ "$FIRST_WINDOW" = false ]; then
                    echo "," >> "$SESSION_FILE"
                fi
                
                cat >> "$SESSION_FILE" << EOF
    {
      "session_id": "pid_$pid",
      "window_id": "$WINDOW_ID",
      "x": $X,
      "y": $Y,
      "width": $WIDTH,
      "height": $HEIGHT,
      "profile": "$profile",
      "title": "$WINDOW_TITLE",
      "working_directory": "$CWD",
      "profile_name": "detected"
EOF
                
                echo "    }" >> "$SESSION_FILE"
                FIRST_WINDOW=false
            fi
        fi
    done
fi

echo "  ]" >> "$SESSION_FILE"
echo "}" >> "$SESSION_FILE"

# Create symlink to latest
ln -sf "$SESSION_FILE" "$HOME/.config/konsole-session-latest.json"

echo "Session saved to $SESSION_FILE"
echo "Latest session: $HOME/.config/konsole-session-latest.json"

# Show summary
python3 << EOF
import json
import os

session_file = os.path.expanduser("~/.config/konsole-session-latest.json")
try:
    with open(session_file, 'r') as f:
        session = json.load(f)
    
    print(f"\nSession Summary:")
    print(f"Timestamp: {session['timestamp']}")
    print(f"Windows: {len(session['windows'])}")
    
    for i, window in enumerate(session['windows'], 1):
        print(f"  Window {i}: {window['profile']} - {window['working_directory']}")
        
except Exception as e:
    print(f"Could not parse session file: {e}")
EOF
