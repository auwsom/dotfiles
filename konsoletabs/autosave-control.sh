#!/bin/bash
# Control script for Konsole autosave daemon

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAEMON_SCRIPT="$SCRIPT_DIR/autosave-daemon.sh"
PID_FILE="$HOME/.config/konsole-autosave.pid"
LOG_FILE="$HOME/.config/konsole-autosave.log"

status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "✅ Autosave daemon is running (PID: $PID)"
            echo "📁 Log file: $LOG_FILE"
            echo "⏰ Saves every 30 minutes"
            echo ""
            echo "Recent log entries:"
            tail -5 "$LOG_FILE" 2>/dev/null || echo "No log entries yet"
        else
            echo "❌ Autosave daemon is not running (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        echo "❌ Autosave daemon is not running"
    fi
}

start() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "Autosave daemon is already running (PID: $PID)"
            return 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    echo "Starting Konsole autosave daemon..."
    nohup "$DAEMON_SCRIPT" > /dev/null 2>&1 &
    PID=$!
    echo "$PID" > "$PID_FILE"
    echo "✅ Autosave daemon started (PID: $PID)"
    echo "📁 Log file: $LOG_FILE"
}

stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID"
            rm -f "$PID_FILE"
            echo "✅ Autosave daemon stopped"
        else
            echo "❌ Autosave daemon was not running"
            rm -f "$PID_FILE"
        fi
    else
        echo "❌ Autosave daemon is not running"
    fi
}

save_now() {
    echo "Saving session now..."
    "$SCRIPT_DIR/save-session-advanced.sh"
}

case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "restart")
        stop
        sleep 2
        start
        ;;
    "status")
        status
        ;;
    "save")
        save_now
        ;;
    "help"|"--help"|"-h"|"")
        echo "Konsole Autosave Controller"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  start    Start autosave daemon (saves every 30 min)"
        echo "  stop     Stop autosave daemon"
        echo "  restart  Restart autosave daemon"
        echo "  status   Show daemon status and recent logs"
        echo "  save     Save session immediately"
        echo "  help     Show this help"
        echo ""
        echo "Log file: $LOG_FILE"
        echo "Session files: $HOME/.config/konsole-session-*.json"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
