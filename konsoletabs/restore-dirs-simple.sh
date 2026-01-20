#!/bin/bash
# Ultra-simple restore - just restore windows in saved directories

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "Restoring session directories..."

# Kill existing windows
pkill -f konsole
sleep 2

# Read JSON and restore windows (simple version)
python3 -c "
import json
import subprocess
import time

with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)

for window in session['windows']:
    # Determine profile
    profile = 'Regular User' if window['profile'] == 'regular' else 'aimgr'
    directory = window['working_directory']
    
    print(f'Restoring window in {directory} as {profile}')
    
    # Start konsole in the saved directory
    cmd = ['konsole', '--profile', profile, '--workdir', directory]
    subprocess.Popen(cmd)
    time.sleep(1)

print('Windows restored. Close this window anytime.')
"

# Keep window open so user can see results
echo ""
echo "Press Enter to close..."
read input
