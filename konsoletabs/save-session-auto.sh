#!/bin/bash
# Automated Konsole session saver - detects current working directories

SESSION_FILE="$HOME/.config/konsole-session-$(date +%Y%m%d-%H%M%S).json"
TEMP_DIR="/tmp/konsole-session-$$"

# Create temp directory for data collection
mkdir -p "$TEMP_DIR"

echo "Saving Konsole session..."

# Get all Konsole processes and their working directories
KONSOLE_PIDS=$(pgrep -f "konsole")

# Initialize JSON
cat > "$SESSION_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "windows": [
EOF

FIRST_WINDOW=true

for pid in $KONSOLE_PIDS; do
    # Get the working directory of the konsole process
    if [ -L "/proc/$pid/cwd" ]; then
        CWD=$(readlink "/proc/$pid/cwd")
        
        # Get window information
        WINDOW_ID=$(xdotool search --pid "$pid" 2>/dev/null | head -1)
        
        if [ -n "$WINDOW_ID" ]; then
            # Get window geometry
            eval $(xdotool getwindowgeometry --shell "$WINDOW_ID" 2>/dev/null)
            
            # Get window title to determine profile
            WINDOW_TITLE=$(xdotool getwindowname "$WINDOW_ID" 2>/dev/null)
            
            # Determine profile type
            if [[ "$WINDOW_TITLE" == *"aimgr"* ]] || [[ "$CWD" == *"avoli"* ]]; then
                PROFILE="aimgr"
            else
                PROFILE="regular"
            fi
            
            # Add comma for all but first window
            if [ "$FIRST_WINDOW" = false ]; then
                echo "," >> "$SESSION_FILE"
            fi
            
            # Add window to JSON
            cat >> "$SESSION_FILE" << EOF
    {
      "id": "$WINDOW_ID",
      "x": $X,
      "y": $Y,
      "width": $WIDTH,
      "height": $HEIGHT,
      "profile": "$PROFILE",
      "title": "$WINDOW_TITLE",
      "working_directory": "$CWD",
      "tabs": [
EOF
            
            # Try to get tab information (this is limited)
            # For now, we'll save the main window directory
            cat >> "$SESSION_FILE" << EOF
        {
          "working_directory": "$CWD",
          "profile": "$PROFILE"
        }
EOF
            
            echo "      ]" >> "$SESSION_FILE"
            echo "    }" >> "$SESSION_FILE"
            
            FIRST_WINDOW=false
        fi
    fi
done

echo "  ]" >> "$SESSION_FILE"
echo "}" >> "$SESSION_FILE"

# Cleanup
rm -rf "$TEMP_DIR"

echo "Session saved to $SESSION_FILE"
echo "Latest session linked to: $HOME/.config/konsole-session-latest.json"
ln -sf "$SESSION_FILE" "$HOME/.config/konsole-session-latest.json"
