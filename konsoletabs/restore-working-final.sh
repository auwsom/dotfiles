#!/bin/bash
# Restore that actually works - just like Fresh Layout

SESSION_FILE="$HOME/.config/konsole-session-latest.json"

echo "=== Restore Konsole Session ==="
echo ""

if [ ! -f "$SESSION_FILE" ]; then
    echo "No session file found. Running fresh layout..."
    exec /home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working
fi

echo "Found saved session with these directories:"
echo ""

# Show saved directories
python3 -c "
import json
with open('$SESSION_FILE', 'r') as f:
    session = json.load(f)
for i, window in enumerate(session['windows']):
    print(f'  Window {i+1}: {window[\"working_directory\"]} ({window[\"profile\"]})')
"

echo ""
echo "Creating fresh layout with tabs..."
echo "After it's done, manually cd to the directories above."
echo ""

# Just run the working fresh layout - DON'T try to exec it
/home/user/git/dotfiles/konsoletabs/setup-working-width.sh.working

echo ""
echo "✅ Layout created!"
echo "Remember to cd to your saved directories."
echo ""
echo "Press Enter to close..."
read input
