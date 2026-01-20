#!/bin/bash
# Restore Konsole session from saved JSON file

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found at $SESSION_FILE"
    echo "Run save-session-auto.sh first to save a session."
    exit 1
fi

echo "Restoring Konsole session from $SESSION_FILE..."

# Parse JSON and restore windows using Python with error handling
python3 << 'EOF'
import json
import subprocess
import time
import os
import re

session_file = os.path.expanduser("~/.config/konsole-session-latest.json")

try:
    with open(session_file, 'r') as f:
        content = f.read()
    
    # Fix JSON by removing newlines in title fields
    content = re.sub(r'"title": "[^"]*\n[^"]*"', '"title": "DBus Error"', content)
    content = re.sub(r'"title": ".*?Error:.*?"', '"title": "DBus Error"', content, flags=re.DOTALL)
    
    session = json.loads(content)
    
    print(f"Restoring session from {session['timestamp']}")
    
    for window in session['windows']:
        print(f"Restoring window: {window.get('title', 'Unknown')}")
        
        # Determine profile and command
        if window['profile'] == 'aimgr':
            profile_name = "aimgr"
            start_cmd = "/home/user/git/dotfiles/konsoletabs/aimgr-simple.sh"
        else:
            profile_name = "Regular User"
            start_cmd = "/bin/bash"
        
        working_dir = window['working_directory']
        
        # Launch konsole with profile and working directory (NEW WINDOW, not tab)
        cmd = [
            'konsole',
            '--profile', profile_name,
            '-e', 'bash', '-c', f'cd "{working_dir}" && exec {start_cmd}'
        ]
        
        print(f"Launching: {' '.join(cmd)}")
        subprocess.Popen(cmd)
        
        # Wait for window to appear
        time.sleep(2)
        
        # Try to position the window
        try:
            result = subprocess.run(['xdotool', 'search', '--class', 'konsole'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                windows = result.stdout.strip().split('\n')
                if windows:
                    # Get the newest window (last in list)
                    latest_window = windows[-1]
                    print(f"Positioning window {latest_window} at ({window['x']}, {window['y']})")
                    subprocess.run(['xdotool', 'windowmove', latest_window, 
                                  str(window['x']), str(window['y'])])
                    subprocess.run(['xdotool', 'windowsize', latest_window,
                                  str(window['width']), str(window['height'])])
                    
                    # Create additional tabs if needed
                    if 'tabs' in window and len(window['tabs']) > 1:
                        print(f"Creating {len(window['tabs'])-1} additional tabs...")
                        for i in range(len(window['tabs']) - 1):
                            subprocess.run(['xdotool', 'key', '--window', latest_window, 'ctrl+shift+t'])
                            time.sleep(0.5)
                            
                            # Switch to correct profile for aimgr tabs
                            if window['profile'] == 'aimgr':
                                subprocess.run(['xdotool', 'type', '--window', latest_window, 
                                              'sudo -u aimgr bash -c \'cd ~/dev/avoli && source /home/user/venv2/bin/activate && exec bash\''])
                                subprocess.run(['xdotool', 'key', '--window', latest_window, 'Return'])
                                time.sleep(1.5)
        except Exception as e:
            print(f"Could not position window: {e}")
        
        # Small delay between windows
        time.sleep(0.5)
    
    print("Session restoration complete")
    
except json.JSONDecodeError as e:
    print(f"Error parsing session file: {e}")
    print("Session file appears to be corrupted. Creating fresh layout instead.")
    # Fallback to creating fresh layout
    subprocess.run(['/home/user/git/dotfiles/konsoletabs/setup-working-width.sh'])
    
except Exception as e:
    print(f"Error restoring session: {e}")
    print("Creating fresh layout instead.")
    subprocess.run(['/home/user/git/dotfiles/konsoletabs/setup-working-width.sh'])
EOF

echo "Done."
