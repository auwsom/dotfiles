#!/bin/bash
# Simple restore - just directories, no complex history

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Creating fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

# Kill existing windows first
pkill -f konsole
sleep 2

echo "Restoring windows in saved directories..."

# Simple Python restore without complex logic
python3 -c "
import json
import subprocess
import time

with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)

for i, window in enumerate(session['windows']):
    profile = 'Regular User' if window['profile'] == 'regular' else 'aimgr'
    directory = window['working_directory']
    
    print(f'Window {i+1}: {directory} ({profile})')
    
    # Start konsole in the right directory
    cmd = ['konsole', '--profile', profile, '--workdir', directory]
    subprocess.Popen(cmd)
    time.sleep(1)

print('Done!')
"

echo ""
echo "✅ Windows restored in saved directories"
echo ""
echo "Press Enter to close..."
read input
