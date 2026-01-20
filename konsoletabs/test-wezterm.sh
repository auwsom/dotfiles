#!/bin/bash
# Test WezTerm with tmux session management

echo "Launching WezTerm with tmux..."
echo "Mouse controls:"
echo "  - Select text with mouse → copies to clipboard"
echo "  - Right-click → paste from clipboard"
echo "  - Middle-click → paste from primary selection"
echo "  - Ctrl+Shift+C → copy selection"
echo "  - Ctrl+Shift+V → paste from clipboard"
echo ""
echo "tmux controls:"
echo "  - Ctrl-b c → new tab"
echo "  - Ctrl-b n/p → next/previous tab"
echo "  - Ctrl-b d → detach session"
echo "  - tmux attach -t session_name → reattach"
echo ""

# Start WezTerm with tmux
wezterm start -- tmux new -s test_session
