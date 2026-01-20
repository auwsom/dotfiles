#!/bin/bash
# Restore that modifies setup during execution

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

# Get saved directories
python3 << 'EOF'
import json

with open('/home/user/.config/konsole-session-latest.json', 'r') as f:
    session = json.load(f)

# Create a modified version of the setup script
with open('/home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working', 'r') as f:
    content = f.read()

# Insert directory changes after window creation but before tab creation
dirs = [w['working_directory'] for w in session['windows']]

# Find the line after window positioning and insert cd commands
lines = content.split('\n')
new_lines = []

for i, line in enumerate(lines):
    new_lines.append(line)
    
    # After window positioning, before tab creation, insert directory changes
    if 'Wait for windows to stabilize' in line:
        new_lines.append('')
        new_lines.append('    # Change to saved directories')
        new_lines.append('    echo "Changing directories to saved locations..."')
        
        for j, (dir_path, profile) in enumerate(zip(dirs, [w['profile'] for w in session['windows']])):
            if j < 4:
                new_lines.append(f'    echo "Window {j+1}: changing to {dir_path} ({profile})"')
                new_lines.append(f'    xdotool windowactivate "${{WINDOW_IDS[{j}]}}"')
                new_lines.append('    sleep 1')
                new_lines.append(f'    xdotool type "cd {dir_path}"')
                new_lines.append('    xdotool key Return')
                new_lines.append('    sleep 0.5')
                
                # Only do sudo switch for aimgr windows if not already in aimgr context
                if profile == 'aimgr' and not dir_path.startswith('/home/aimgr'):
                    new_lines.append('    # Switch to aimgr user')
                    new_lines.append(f'    xdotool type "sudo -u aimgr bash -c \'cd {dir_path} && exec bash\'"')
                    new_lines.append('    xdotool key Return')
                    new_lines.append('    sleep 1')
                    new_lines.append('    xdotool type "sv2"')
                    new_lines.append('    xdotool key Return')
                    new_lines.append('    sleep 0.5')
        
        new_lines.append('')
        new_lines.append('    # Wait for directories to change')
        new_lines.append('    sleep 2')

# Write the modified script
with open('/tmp/setup_with_dirs.sh', 'w') as f:
    f.write('\n'.join(new_lines))

import os
os.chmod('/tmp/setup_with_dirs.sh', 0o755)
EOF

echo "Running modified setup with saved directories..."
echo ""

# Run the modified setup
exec /tmp/setup_with_dirs.sh
