#!/bin/bash
# Test single window directory restore

echo "Testing single window directory restore..."
echo ""

# Test 1: Try --workdir parameter
echo "Test 1: konsole --workdir /tmp --profile Regular User"
konsole --workdir /tmp --profile "Regular User" &
sleep 3

# Check if it worked
echo "Checking if window opened in /tmp..."
python3 -c "
import subprocess
result = subprocess.run(['xdotool', 'search', '--class', 'konsole'], capture_output=True, text=True)
if result.returncode == 0:
    windows = result.stdout.strip().split('\n')
    for window_id in windows[:1]:  # Just check first window
        try:
            # Get bash processes for this window
            ps_result = subprocess.run(['ps', '-eo', 'pid,ppid,cmd'], capture_output=True, text=True)
            for line in ps_result.stdout.split('\n'):
                if window_id in line and 'bash' in line:
                    pid = line.split()[0]
                    try:
                        import os
                        cwd = os.readlink(f'/proc/{pid}/cwd')
                        print(f'Window {window_id} bash process {pid} is in: {cwd}')
                    except:
                        print(f'Could not read cwd for pid {pid}')
        except Exception as e:
            print(f'Error: {e}')
"

echo ""
echo "Test 2: Using -e bash -c 'cd /tmp && exec bash'"
konsole --profile "Regular User" -e bash -c 'cd /tmp && exec bash' &
sleep 3

# Check this one too
echo "Checking second window..."
python3 -c "
import subprocess
result = subprocess.run(['xdotool', 'search', '--class', 'konsole'], capture_output=True, text=True)
if result.returncode == 0:
    windows = result.stdout.strip().split('\n')
    for window_id in windows[1:2]:  # Check second window
        try:
            ps_result = subprocess.run(['ps', '-eo', 'pid,ppid,cmd'], capture_output=True, text=True)
            for line in ps_result.stdout.split('\n'):
                if window_id in line and 'bash' in line:
                    pid = line.split()[0]
                    try:
                        import os
                        cwd = os.readlink(f'/proc/{pid}/cwd')
                        print(f'Window {window_id} bash process {pid} is in: {cwd}')
                    except:
                        print(f'Could not read cwd for pid {pid}')
        except Exception as e:
            print(f'Error: {e}')
"

echo ""
echo "Test complete. Close windows manually."
echo "Press Enter to close this test..."
read input
