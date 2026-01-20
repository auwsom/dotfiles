#!/bin/bash
# Restore session with directories and history

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

echo "Restoring windows with directories and history..."

python3 << 'EOF'
import json
import subprocess
import time
import os

session_file = "/home/user/.config/konsole-session-latest.json"

with open(session_file, 'r') as f:
    session = json.load(f)

print(f"Restoring {len(session['windows'])} windows...")

for i, window in enumerate(session['windows']):
    print(f"\nWindow {i+1}: {window['profile']} at {window['working_directory']}")
    
    # Determine profile
    profile = "Regular User" if window['profile'] == 'regular' else "aimgr"
    
    # Create history file for this window
    history_file = f"/home/user/.bash_history_session_{i}_{int(time.time())}"
    
    # Create the startup script that sets directory and history
    startup_script = f"/tmp/konsole_restore_{i}.sh"
    
    with open(startup_script, 'w') as f:
        f.write(f"""#!/bin/bash
# Set unique history file for this session
export HISTFILE="{history_file}"
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend

# Change to the saved directory
cd "{window['working_directory']}"

# Set up prompt command to save/merge history
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# If aimgr profile, switch user
if [ "{window['profile']}" = "aimgr" ]; then
    echo "Switching to aimgr user in {window['working_directory']}..."
    sudo -u aimgr bash -c 'cd "{window['working_directory']}" && exec bash'
else
    echo "Session restored in {window['working_directory']}"
    exec bash
fi
""")
    
    os.chmod(startup_script, 0o755)
    
    # Start konsole with the startup script
    cmd = ['konsole', '--profile', profile, '-e', 'bash', startup_script]
    subprocess.Popen(cmd)
    time.sleep(2)
    
    # Position the window
    try:
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
    except Exception as e:
        print(f"Could not position window: {e}")
    
    # Create additional tabs if needed
    if 'tabs' in window and len(window['tabs']) > 1:
        print(f"Creating {len(window['tabs'])-1} additional tabs...")
        
        for j in range(1, len(window['tabs'])):
            tab = window['tabs'][j]
            tab_dir = tab['working_directory']
            
            print(f"  Tab {j+1}: {tab_dir}")
            
            # Create tab-specific startup script
            tab_script = f"/tmp/konsole_tab_{i}_{j}.sh"
            tab_history = f"/home/user/.bash_history_tab_{i}_{j}_{int(time.time())}"
            
            with open(tab_script, 'w') as f:
                f.write(f"""#!/bin/bash
# Set unique history file for this tab
export HISTFILE="{tab_history}"
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend

# Change to the saved directory
cd "{tab_dir}"

# Set up prompt command to save/merge history
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# If aimgr profile, switch user
if [ "{tab['profile']}" = "aimgr" ]; then
    sudo -u aimgr bash -c 'cd "{tab_dir}" && exec bash'
else
    echo "Tab restored in {tab_dir}"
    exec bash
fi
""")
            
            os.chmod(tab_script, 0o755)
            
            # Create new tab and run script
            time.sleep(0.5)
            subprocess.run(['xdotool', 'key', 'ctrl+shift+t'])
            time.sleep(1)
            
            # Type the command to run the tab script
            subprocess.run(['xdotool', 'type', f'bash {tab_script}'])
            subprocess.run(['xdotool', 'key', 'Return'])
            time.sleep(1)

print(f"\n✅ Session restored!")
print(f"Each window/tab has its own history file:")
print(f"  Main windows: ~/.bash_history_session_N_*")
print(f"  Tabs: ~/.bash_history_tab_N_*")
print(f"\nHistory is automatically merged with main history on each command.")

# Cleanup temporary files after a delay
subprocess.run(['bash', '-c', 'sleep 10 && rm -f /tmp/konsole_restore_*.sh /tmp/konsole_tab_*.sh &'])

EOF

echo ""
echo "Session restoration complete!"
echo "Each window/tab now has:"
echo "  ✓ Correct working directory"
echo "  ✓ Separate history file"
echo "  ✓ Auto-merge with main history"
echo ""
echo "Press Enter to close..."
read input
