#!/bin/bash
# Final working restore

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "=== Restore Konsole Session ==="
echo ""

echo "Your saved directories were:"
python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)
for i, w in enumerate(session['windows']):
    print(f'  Window {i+1}: {w[\"working_directory\"]} ({w[\"profile\"]})')
"

echo ""
echo "Running fresh layout..."
echo "After it completes, manually cd to these directories:"
echo "  Window 2-4: cd /home/user"
echo ""

# Just run the fresh layout - it works and stays open
exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
