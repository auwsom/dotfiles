#!/bin/bash

# Modify the profile command in the Konsole config
PROFILE_PATH="$HOME/.config/konsolerc"
PROFILE_CMD='Exec=nohup terminator --new-tab &'

# Update the profile command to launch Terminator in a new tab
sed -i "s|Exec=.*|$PROFILE_CMD|" "$PROFILE_PATH"

# Open a new Konsole tab
konsole --new-tab

# Wait a moment to ensure the tab opens
sleep 5

# Check if Terminator is running
if pgrep terminator > /dev/null; then
  echo "Terminator is still running"
else
  echo "Terminator is not running"
fi

