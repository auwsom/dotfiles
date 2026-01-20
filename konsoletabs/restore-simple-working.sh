#!/bin/bash
# Simple restore that actually restores directories

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Creating fresh layout..."
    /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
    exit 0
fi

echo "Restoring session from: $SESSION_FILE"

# Kill existing windows first
pkill -f konsole
sleep 2

# Parse JSON and restore windows
python3 << 'EOF'
import json
import subprocess
import time

session_file = "/home/user/.config/konsole-session-latest.json"

try:
    with open(session_file, 'r') as f:
        session = json.load(f)
    
    print(f"Restoring {len(session['windows'])} windows...")
    
    for window in session['windows']:
        print(f"Window: {window['working_directory']} ({window['profile']})")
        
        # Determine profile
        profile = "Regular User" if window['profile'] == 'regular' else "aimgr"
        
        # Start konsole in the correct directory
        if window['profile'] == 'aimgr':
            # For aimgr, start in the saved directory then switch user
            cmd = ['konsole', '--profile', profile, '-e', 'bash', '-c', 
                   f'cd "{window["working_directory"]}" && exec bash']
        else:
            # For regular user, just start in the directory
            cmd = ['konsole', '--profile', profile, '-e', 'bash', '-c', 
                   f'cd "{window["working_directory"]}" && exec bash']
        
        subprocess.Popen(cmd)
        time.sleep(2)
        
        # Position the window
        result = subprocess.run(['xdotool', 'search', '--class', 'konsole'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            windows = result.stdout.strip().split('\n')
            if windows:
                latest_window = windows[-1]
                subprocess.run(['xdotool', 'windowmove', latest_window, 
                              str(window['x']), str(window['y'])])
                subprocess.run(['xdotool', 'windowsize', latest_window,
                              str(window['width']), str(window['height'])])
    
    print("Windows restored. Setting up tabs...")
    time.sleep(3)
    
    # Now set up tabs and user switching
    windows = session['windows']
    konsole_windows = subprocess.run(['xdotool', 'search', '--class', 'konsole'], 
                                   capture_output=True, text=True).stdout.strip().split('\n')
    
    for i, window in enumerate(windows):
        if i >= len(konsole_windows):
            break
            
        window_id = konsole_windows[i]
        
        # Create additional tabs if needed
        if 'tabs' in window and len(window['tabs']) > 1:
            for j in range(1, len(window['tabs'])):
                subprocess.run(['xdotool', 'key', '--window', window_id, 'ctrl+shift+t'])
                time.sleep(0.5)
                
                # Set directory for the new tab
                tab_dir = window['tabs'][j]['working_directory']
                if window['profile'] == 'aimgr':
                    # For aimgr tabs, switch user and go to directory
                    subprocess.run(['xdotool', 'type', '--window', window_id, 
                                  f'sudo -u aimgr bash -c \'cd "{tab_dir}" && exec bash\''])
                else:
                    # For regular tabs, just change directory
                    subprocess.run(['xdotool', 'type', '--window', window_id, f'cd "{tab_dir}"'])
                
                subprocess.run(['xdotool', 'key', '--window', window_id, 'Return'])
                time.sleep(1)
        
        # Also set up the first tab if it's aimgr
        if window['profile'] == 'aimgr':
            subprocess.run(['xdotool', 'type', '--window', window_id, 
                          f'sudo -u aimgr bash -c \'cd "{window["working_directory"]}" && exec bash\''])
            subprocess.run(['xdotool', 'key', '--window', window_id, 'Return'])
            time.sleep(1)
    
    print("Session restore complete!")
    
except Exception as e:
    print(f"Error: {e}")
    print("Creating fresh layout instead...")
    subprocess.run(['/home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working'])
EOF
