#!/bin/bash
# Save current Konsole session state (tabs, directories, users)

SAVE_DIR="$HOME/.config/konsole-sessions"
SAVE_FILE="$SAVE_DIR/session_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$SAVE_DIR"

echo "# Konsole Session State - $(date)" > "$SAVE_FILE"
echo "# Format: WINDOW_ID:USER:DIRECTORY:PROFILE" >> "$SAVE_FILE"
echo "" >> "$SAVE_FILE"

# Get all Konsole windows
WINDOW_IDS=($(xdotool search --class "konsole"))

echo "Saving session state for ${#WINDOW_IDS[@]} windows..."

for i in "${!WINDOW_IDS[@]}"; do
    WID="${WINDOW_IDS[$i]}"
    
    # Get window PID
    WINDOW_PID=$(xprop -id $WID | grep "_NET_WM_PID" | awk '{print $3}')
    
    if [ -n "$WINDOW_PID" ]; then
        # Get all sessions/tabs for this window
        SESSIONS=$(qdbus org.kde.konsole /Sessions/listSessions 2>/dev/null)
        
        if [ -n "$SESSIONS" ]; then
            while read -r session; do
                # Get working directory and process info
                PROCESS_ID=$(qdbus org.kde.konsole $session processId 2>/dev/null)
                if [ -n "$PROCESS_ID" ]; then
                    CWD=$(pwdx $PROCESS_ID 2>/dev/null | sed 's/^[0-9]*: //')
                    USER=$(ps -o user= -p $PROCESS_ID 2>/dev/null | tr -d ' ')
                    
                    echo "WINDOW_$((i+1))_TAB:$USER:$CWD:Regular" >> "$SAVE_FILE"
                fi
            done <<< "$SESSIONS"
        fi
    fi
done

echo "" >> "$SAVE_FILE"
echo "# Window positions:" >> "$SAVE_FILE"
for i in "${!WINDOW_IDS[@]}"; do
    WID="${WINDOW_IDS[$i]}"
    GEOMETRY=$(xgetgeometry $WID 2>/dev/null || xdotool getwindowgeometry $WID)
    echo "WINDOW_$((i+1))_POS:$GEOMETRY" >> "$SAVE_FILE"
done

echo "Session saved to: $SAVE_FILE"
echo "Total windows/tabs saved: $(grep -c "WINDOW_" "$SAVE_FILE")"
