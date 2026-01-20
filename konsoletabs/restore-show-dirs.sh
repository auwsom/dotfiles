#!/bin/bash
# Super simple restore - just change directories in existing windows

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Creating fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "Restoring directories..."

# Read the saved directories
python3 -c "
import json

with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)

dirs = [w['working_directory'] for w in session['windows']]
print('Saved directories:')
for i, d in enumerate(dirs):
    print(f'  Window {i+1}: {d}')
"

echo ""
echo "Please use the Fresh Layout button, then manually change directories to:"
echo "  Window 1: $(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['windows'][0]['working_directory'])")"
echo "  Window 2: $(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['windows'][1]['working_directory'])")"
echo "  Window 3: $(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['windows'][2]['working_directory'])")"
echo "  Window 4: $(python3 -c "import json; print(json.load(open('$SESSION_FILE'))['windows'][3]['working_directory'])")"

echo ""
echo "Press Enter to close..."
read input
