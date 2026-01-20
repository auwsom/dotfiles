#!/bin/bash
# Restore that actually changes directories

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

# Extract saved directories
python3 << 'PYTHON_EOF'
import json

session_file = "/home/user/.config/konsole-session-latest.json"

with open(session_file, 'r') as f:
    session = json.load(f)

dirs = []
profiles = []
for window in session['windows']:
    dirs.append(window['working_directory'])
    profiles.append(window['profile'])

print(f"SAVED_DIR_1='{dirs[0]}'")
print(f"SAVED_PROFILE_1='{profiles[0]}'")
print(f"SAVED_DIR_2='{dirs[1]}'")
print(f"SAVED_PROFILE_2='{profiles[1]}'")
print(f"SAVED_DIR_3='{dirs[2]}'")
print(f"SAVED_PROFILE_3='{profiles[2]}'")
print(f"SAVED_DIR_4='{dirs[3]}'")
print(f"SAVED_PROFILE_4='{profiles[3]}'")
PYTHON_EOF

# Save to file
python3 << 'PYTHON_EOF'
import json

session_file = "/home/user/.config/konsole-session-latest.json"

with open(session_file, 'r') as f:
    session = json.load(f)

dirs = []
profiles = []
for window in session['windows']:
    dirs.append(window['working_directory'])
    profiles.append(window['profile'])

with open('/tmp/saved_dirs.txt', 'w') as f:
    f.write(f"SAVED_DIR_1='{dirs[0]}'\n")
    f.write(f"SAVED_PROFILE_1='{profiles[0]}'\n")
    f.write(f"SAVED_DIR_2='{dirs[1]}'\n")
    f.write(f"SAVED_PROFILE_2='{profiles[1]}'\n")
    f.write(f"SAVED_DIR_3='{dirs[2]}'\n")
    f.write(f"SAVED_PROFILE_3='{profiles[2]}'\n")
    f.write(f"SAVED_DIR_4='{dirs[3]}'\n")
    f.write(f"SAVED_PROFILE_4='{profiles[3]}'\n")
PYTHON_EOF

# Source the saved directories
source /tmp/saved_dirs.txt

echo "Restoring directories:"
echo "  Window 1: $SAVED_DIR_1 ($SAVED_PROFILE_1)"
echo "  Window 2: $SAVED_DIR_2 ($SAVED_PROFILE_2)"
echo "  Window 3: $SAVED_DIR_3 ($SAVED_PROFILE_3)"
echo "  Window 4: $SAVED_DIR_4 ($SAVED_PROFILE_4)"
echo ""

# Kill existing windows
pkill -f konsole
sleep 2

# Create modified setup script that uses saved directories
cat > /tmp/setup_with_saved_dirs.sh << EOF
#!/bin/bash
# Modified setup with saved directories

echo "Setting up 4 Konsole windows in saved directories..."

# Screen dimensions
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2050
WINDOW_HEIGHT=\$SCREEN_HEIGHT
WINDOW_WIDTH=1200
WINDOW_START_Y=0
WINDOW4_X=\$((SCREEN_WIDTH - WINDOW_WIDTH))
SPACING=\$((WINDOW4_X / 3))
WINDOW1_X=0
WINDOW2_X=\$SPACING
WINDOW3_X=\$((SPACING * 2))
WINDOW4_X=\$((SPACING * 3))

echo "Starting Window 1: Regular user, 8 tabs in $SAVED_DIR_1"
nohup konsole --profile "Regular User" &
sleep 3

echo "Starting Window 2: aimgr user, 3 tabs in $SAVED_DIR_2"
nohup konsole --profile "aimgr" &
sleep 2

echo "Starting Window 3: aimgr user, 3 tabs in $SAVED_DIR_3"
nohup konsole --profile "aimgr" &
sleep 2

echo "Starting Window 4: aimgr user, 3 tabs in $SAVED_DIR_4"
nohup konsole --profile "aimgr" &
sleep 3

# Get windows and position them
ALL_WINDOW_IDS=(\$(xdotool search --class "konsole" 2>/dev/null))
WINDOW_IDS=("\${ALL_WINDOW_IDS[@]: -4}")

# Position windows
xdotool windowmove "\${WINDOW_IDS[0]}" \$WINDOW1_X \$WINDOW_START_Y
xdotool windowsize "\${WINDOW_IDS[0]}" \$WINDOW_WIDTH \$WINDOW_HEIGHT
xdotool windowmove "\${WINDOW_IDS[1]}" \$WINDOW2_X \$WINDOW_START_Y
xdotool windowsize "\${WINDOW_IDS[1]}" \$WINDOW_WIDTH \$WINDOW_HEIGHT
xdotool windowmove "\${WINDOW_IDS[2]}" \$WINDOW3_X \$WINDOW_START_Y
xdotool windowsize "\${WINDOW_IDS[2]}" \$WINDOW_WIDTH \$WINDOW_HEIGHT
xdotool windowmove "\${WINDOW_IDS[3]}" \$WINDOW4_X \$WINDOW_START_Y
xdotool windowsize "\${WINDOW_IDS[3]}" \$WINDOW_WIDTH \$WINDOW_HEIGHT

sleep 2

echo "Changing directories to saved locations..."

# Change directory in Window 1
xdotool windowactivate "\${WINDOW_IDS[0]}"
sleep 1
xdotool type "cd $SAVED_DIR_1"
xdotool key Return
sleep 0.5

# Create tabs and change directories for Window 2 (aimgr)
xdotool windowactivate "\${WINDOW_IDS[1]}"
sleep 1
xdotool type "cd $SAVED_DIR_2"
xdotool key Return
sleep 0.5
xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_2 && exec bash'"
xdotool key Return
sleep 1
xdotool type "sv2"
xdotool key Return
sleep 0.5

# Create additional tabs for Window 2
for i in \$(seq 1 2); do
    xdotool key ctrl+shift+t
    sleep 1
    xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_2 && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

# Same for Window 3
xdotool windowactivate "\${WINDOW_IDS[2]}"
sleep 1
xdotool type "cd $SAVED_DIR_3"
xdotool key Return
sleep 0.5
xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_3 && exec bash'"
xdotool key Return
sleep 1
xdotool type "sv2"
xdotool key Return
sleep 0.5

for i in \$(seq 1 2); do
    xdotool key ctrl+shift+t
    sleep 1
    xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_3 && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

# Same for Window 4
xdotool windowactivate "\${WINDOW_IDS[3]}"
sleep 1
xdotool type "cd $SAVED_DIR_4"
xdotool key Return
sleep 0.5
xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_4 && exec bash'"
xdotool key Return
sleep 1
xdotool type "sv2"
xdotool key Return
sleep 0.5

for i in \$(seq 1 2); do
    xdotool key ctrl+shift+t
    sleep 1
    xdotool type "sudo -u aimgr bash -c 'cd $SAVED_DIR_4 && exec bash'"
    xdotool key Return
    sleep 1
    xdotool type "sv2"
    xdotool key Return
    sleep 0.5
done

echo "✅ Restore complete!"
EOF

chmod +x /tmp/setup_with_saved_dirs.sh

# Run the modified setup
/tmp/setup_with_saved_dirs.sh

echo ""
echo "Press Enter to cleanup and close..."
read input

# Cleanup
rm -f /tmp/saved_dirs.txt /tmp/setup_with_saved_dirs.sh
