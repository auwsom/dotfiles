#!/bin/bash
# Ultra-simple restore - just show directories and use fresh layout

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

echo "Found saved session. Creating fresh layout..."
echo ""
echo "Your saved directories were:"

# Show saved directories
python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)
for i, window in enumerate(session['windows']):
    print(f'  Window {i+1}: {window[\"working_directory\"]} ({window[\"profile\"]})')
"

echo ""
echo "Running fresh layout - you can cd to these directories manually..."
echo ""

# Just run the fresh layout
exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
