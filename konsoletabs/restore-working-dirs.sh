#!/bin/bash
# Working restore - modify setup to use saved directories

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

# Extract saved directories to a temp file
python3 << 'EOF'
import json

session_file = "/home/user/.config/konsole-session-latest.json"

with open(session_file, 'r') as f:
    session = json.load(f)

# Create a bash script with the saved directories
with open('/tmp/saved_dirs.sh', 'w') as f:
    f.write('#!/bin/bash\n')
    f.write('# Saved directories for restore\n')
    for i, window in enumerate(session['windows']):
        f.write(f'SAVED_DIR_{i+1}="{window["working_directory"]}"\n')
    f.write(f'SAVED_PROFILE_{i+1}="{window["profile"]}"\n')

EOF

chmod +x /tmp/saved_dirs.sh

# Source the saved directories
source /tmp/saved_dirs.sh

echo "Restoring with saved directories:"
for i in {1..4}; do
    var_name="SAVED_DIR_$i"
    profile_name="SAVED_PROFILE_$i"
    if [ -n "${!var_name}" ]; then
        echo "  Window $i: ${!var_name} (${!profile_name})"
    fi
done

echo ""

# Kill existing windows
pkill -f konsole
sleep 2

# Start windows with custom startup scripts that change to saved directories
echo "Starting windows in saved directories..."

# Window 1
if [ -n "$SAVED_DIR_1" ]; then
    cat > /tmp/restore_window_1.sh << EOF
#!/bin/bash
cd "$SAVED_DIR_1"
echo "Restored to: $(pwd)"
exec bash
EOF
    chmod +x /tmp/restore_window_1.sh
    konsole --profile "Regular User" -e /tmp/restore_window_1.sh &
fi

sleep 2

# Window 2 (aimgr)
if [ -n "$SAVED_DIR_2" ]; then
    cat > /tmp/restore_window_2.sh << EOF
#!/bin/bash
cd "$SAVED_DIR_2"
echo "Restored to: $(pwd)"
sudo -u aimgr bash -c 'cd "$SAVED_DIR_2" && exec bash'
EOF
    chmod +x /tmp/restore_window_2.sh
    konsole --profile "aimgr" -e /tmp/restore_window_2.sh &
fi

sleep 2

# Window 3 (aimgr)  
if [ -n "$SAVED_DIR_3" ]; then
    cat > /tmp/restore_window_3.sh << EOF
#!/bin/bash
cd "$SAVED_DIR_3"
echo "Restored to: $(pwd)"
sudo -u aimgr bash -c 'cd "$SAVED_DIR_3" && exec bash'
EOF
    chmod +x /tmp/restore_window_3.sh
    konsole --profile "aimgr" -e /tmp/restore_window_3.sh &
fi

sleep 2

# Window 4 (aimgr)
if [ -n "$SAVED_DIR_4" ]; then
    cat > /tmp/restore_window_4.sh << EOF
#!/bin/bash
cd "$SAVED_DIR_4"
echo "Restored to: $(pwd)"
sudo -u aimgr bash -c 'cd "$SAVED_DIR_4" && exec bash'
EOF
    chmod +x /tmp/restore_window_4.sh
    konsole --profile "aimgr" -e /tmp/restore_window_4.sh &
fi

sleep 3

echo ""
echo "✅ Windows restored in saved directories!"
echo ""
echo "Press Enter to close..."
read input

# Cleanup
rm -f /tmp/saved_dirs.sh /tmp/restore_window_*.sh
