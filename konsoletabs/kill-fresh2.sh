#!/bin/bash

# Kill the fresh2 script processes
echo "Killing fresh2 script processes..."

# Kill the setup script
pkill -f "setup-custom-dirs.sh"

# Kill any xdotool processes that might be stuck
pkill -f "xdotool"

# Kill any konsole profile fixing processes
pkill -f "fix-konsole-profiles.sh"

echo "Fresh2 script processes killed."
