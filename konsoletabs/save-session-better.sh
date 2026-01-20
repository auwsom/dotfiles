#!/bin/bash
# Better save that captures actual tab directories

SESSION_FILE="$HOME/.config/konsole-session-$(date +%Y%m%d-%H%M%S).json"

echo "=== Save Konsole Session (Better Version) ==="
echo ""

# Get all konsole windows and their tabs
echo "Finding all Konsole tabs..."

python3 << 'EOF'
import json
import subprocess
import os
import time

def get_tab_info():
    windows = []
    
    # Get all konsole main processes
    result = subprocess.run(['ps', '-eo', 'pid,cmd'], capture_output=True, text=True)
    konsole_pids = []
    for line in result.stdout.split('\n'):
        if 'konsole --profile' in line and 'grep' not in line:
            pid = line.split()[0]
            konsole_pids.append(pid)
    
    print(f"Found {len(konsole_pids)} Konsole windows")
    
    for konsole_pid in konsole_pids:
        # Get window info
        try:
            # Find all bash processes under this konsole
            bash_result = subprocess.run(['ps', '-eo', 'pid,ppid,cmd'], 
                                       capture_output=True, text=True)
            
            bash_pids = []
            for line in bash_result.stdout.split('\n'):
                if konsole_pid in line and ('bash' in line or 'zsh' in line):
                    parts = line.split()
                    if len(parts) >= 3:
                        bash_pid = parts[0]
                        bash_ppid = parts[1]
                        if bash_ppid == konsole_pid or 'sudo' in line:
                            bash_pids.append(bash_pid)
            
            # Get window geometry
            window_id = None
            try:
                xdotool_result = subprocess.run(['xdotool', 'search', '--pid', konsole_pid], 
                                              capture_output=True, text=True)
                if xdotool_result.returncode == 0:
                    window_id = xdotool_result.stdout.strip().split('\n')[0]
            except:
                pass
            
            # Get window geometry
            x, y, width, height = 0, 0, 1200, 2050
            if window_id:
                try:
                    geo_result = subprocess.run(['xdotool', 'getwindowgeometry', '--shell', window_id], 
                                              capture_output=True, text=True)
                    for line in geo_result.stdout.split('\n'):
                        if line.startswith('X='):
                            x = int(line.split('=')[1])
                        elif line.startswith('Y='):
                            y = int(line.split('=')[1])
                        elif line.startswith('WIDTH='):
                            width = int(line.split('=')[1])
                        elif line.startswith('HEIGHT='):
                            height = int(line.split('=')[1])
                except:
                    pass
            
            # Get window title to determine profile
            title = "Konsole"
            profile = "regular"
            if window_id:
                try:
                    title_result = subprocess.run(['xdotool', 'getwindowname', window_id], 
                                                capture_output=True, text=True)
                    if title_result.returncode == 0:
                        title = title_result.stdout.strip()
                        if 'aimgr' in title.lower():
                            profile = "aimgr"
                except:
                    pass
            
            # Get working directories for each tab
            tabs = []
            for bash_pid in bash_pids:
                try:
                    cwd = os.readlink(f"/proc/{bash_pid}/cwd")
                    
                    # For aimgr processes, check if we can get the actual aimgr directory
                    if profile == "aimgr":
                        # Try to get the directory from the sudo process
                        ps_result = subprocess.run(['ps', '-eo', 'pid,ppid,cmd'], 
                                                  capture_output=True, text=True)
                        for line in ps_result.stdout.split('\n'):
                            if bash_pid in line and 'sudo -u aimgr' in line:
                                # Extract the directory from the sudo command
                                import re
                                match = re.search(r'cd\s+([^\s&]+)', line)
                                if match:
                                    cwd = match.group(1).strip("'\"")
                                    break
                    
                    tabs.append({
                        "working_directory": cwd,
                        "profile": profile
                    })
                except:
                    # Fallback for aimgr
                    if profile == "aimgr":
                        tabs.append({
                            "working_directory": "/home/aimgr",
                            "profile": profile
                        })
                    else:
                        tabs.append({
                            "working_directory": "/home/user",
                            "profile": profile
                        })
            
            if not tabs:
                # Fallback to konsole process directory
                try:
                    cwd = os.readlink(f"/proc/{konsole_pid}/cwd")
                    tabs.append({
                        "working_directory": cwd,
                        "profile": profile
                    })
                except:
                    tabs.append({
                        "working_directory": "/home/user",
                        "profile": profile
                    })
            
            windows.append({
                "id": konsole_pid,
                "x": x,
                "y": y,
                "width": width,
                "height": height,
                "profile": profile,
                "title": title,
                "working_directory": tabs[0]["working_directory"],
                "tabs": tabs
            })
            
            print(f"Window {konsole_pid}: {len(tabs)} tabs, profile={profile}")
            for i, tab in enumerate(tabs):
                print(f"  Tab {i+1}: {tab['working_directory']}")
            
        except Exception as e:
            print(f"Error processing window {konsole_pid}: {e}")
    
    return windows

# Get session data
windows = get_tab_info()

session_data = {
    "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
    "windows": windows
}

# Save to file
session_file = f"/home/user/.config/konsole-session-{time.strftime('%Y%m%d-%H%M%S')}.json"
with open(session_file, 'w') as f:
    json.dump(session_data, f, indent=2)

# Update latest link
latest_link = "/home/user/.config/konsole-session-latest.json"
if os.path.exists(latest_link):
    os.remove(latest_link)
os.symlink(session_file, latest_link)

print(f"\nSession saved to: {session_file}")
print(f"Latest session linked to: {latest_link}")
print(f"Saved {len(windows)} windows with {sum(len(w['tabs']) for w in windows)} total tabs")
EOF

echo ""
echo "✅ Session saved successfully!"
echo ""
echo "Press Enter to close..."
read input
