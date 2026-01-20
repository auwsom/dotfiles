#!/bin/bash
# Konsole Session Manager - Easy interface for session management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo "Konsole Session Manager"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup       Create the standard 4-window layout"
    echo "  restore     Restore last saved session"
    echo "  save        Save current session"
    echo "  save-adv    Advanced save with better tab detection"
    echo "  autosave    Control autosave daemon (start/stop/status)"
    echo "  help        Show this help message"
    echo ""
    echo "Autosave usage:"
    echo "  $0 autosave start    # Start 30-min autosave daemon"
    echo "  $0 autosave stop     # Stop autosave daemon"
    echo "  $0 autosave status   # Check daemon status"
    echo "  $0 autosave save     # Save session immediately"
    echo ""
    echo "Examples:"
    echo "  $0 setup    # Create your standard layout"
    echo "  $0 save     # Save current session"
    echo "  $0 restore  # Restore saved session"
}

case "$1" in
    "setup")
        echo "Creating standard Konsole layout..."
        "$SCRIPT_DIR/setup-with-session.sh"
        ;;
    "restore")
        echo "Restoring saved session..."
        "$SCRIPT_DIR/restore-session-auto.sh"
        ;;
    "save")
        echo "Saving current session..."
        "$SCRIPT_DIR/save-session-auto.sh"
        ;;
    "save-adv")
        echo "Advanced session saving..."
        "$SCRIPT_DIR/save-session-advanced.sh"
        ;;
    "autosave")
        shift
        "$SCRIPT_DIR/autosave-control.sh" "$@"
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
