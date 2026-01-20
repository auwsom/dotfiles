# Konsole Session Manager

A solution for preserving Konsole tabs, windows, and working directories across restarts on Kubuntu.

## Features

- **Window Layout Preservation**: Saves and restores the exact position and size of Konsole windows
- **Working Directory Memory**: Remembers which directory each tab was in
- **Profile Support**: Maintains user profiles (regular user vs aimgr user)
- **Session Management**: Save and restore sessions on demand
- **Automatic Backup**: Background daemon saves your session every 30 minutes
- **Startup Integration**: Automatically starts the autosave daemon on login

## Files

- `konsole-manager.sh` - Main interface for session management
- `setup-with-session.sh` - Creates the standard 4-window layout
- `save-session-auto.sh` - Basic session saver
- `save-session-advanced.sh` - Advanced session saver with better tab detection
- `restore-session-auto.sh` - Restores saved sessions
- `autosave-daemon.sh` - Background daemon that saves every 30 minutes
- `autosave-control.sh` - Control script for the autosave daemon
- `aimgr-simple.sh` - Wrapper for aimgr user switching

## Usage

### Basic Commands

```bash
# Create your standard 4-window layout
./konsole-manager.sh setup

# Save current session
./konsole-manager.sh save

# Restore last saved session
./konsole-manager.sh restore

# Advanced save (better tab detection)
./konsole-manager.sh save-adv
```

### Autosave Commands

```bash
# Start 30-minute autosave daemon
./konsole-manager.sh autosave start

# Stop autosave daemon
./konsole-manager.sh autosave stop

# Check autosave status
./konsole-manager.sh autosave status

# Save session immediately
./konsole-manager.sh autosave save

# Restart autosave daemon
./konsole-manager.sh autosave restart
```

### Desktop Integration

**3 Desktop Shortcuts Created:**

1. **Save Konsole Session** (`save-konsole.desktop`)
   - Saves current session manually
   - Shows success/failure messages
   - Waits for user input before closing

2. **Restore Konsole Session** (`restore-konsole-new.desktop`)
   - Restores from saved session
   - Falls back to fresh layout if restore fails
   - Shows progress and waits for completion

3. **Fresh Konsole Layout** (`fresh-konsole.desktop`)
   - Creates new 4-window layout
   - Spans full 3840px width
   - Uses working overlap configuration

All shortcuts are available both on Desktop and in `/home/user/git/dotfiles/konsoletabs/`

A desktop shortcut has been created at:
`~/.local/share/applications/konsole-session-manager.desktop`

You can find it in your application menu as "Konsole Session Manager".

## Standard Layout

The setup creates 4 overlapping windows:

1. **Window 1** (left): Regular user, 8 tabs
2. **Window 2** (center-left): aimgr user, 3 tabs in ~/dev/avoli
3. **Window 3** (center-right): aimgr user, 3 tabs in ~/dev/avoli  
4. **Window 4** (right): Regular user, 3 tabs

Each window is 960x1940 pixels, evenly spaced across a 3840px display.

## Session Files

Sessions are saved in JSON format to:
- `~/.config/konsole-session-YYYYMMDD-HHMMSS.json` - Timestamped sessions
- `~/.config/konsole-session-latest.json` - Always points to the latest session

## Autosave Daemon

The autosave daemon runs in the background and automatically saves your session every 30 minutes:

- **Log file**: `~/.config/konsole-autosave.log`
- **PID file**: `~/.config/konsole-autosave.pid`
- **Automatic cleanup**: Keeps only the last 10 session files to save space
- **Startup integration**: Automatically starts when you log in (via `~/.config/autostart/`)

## How It Works

1. **Window Detection**: Uses xdotool to find Konsole windows and their positions
2. **Process Tracking**: Tracks Konsole processes to determine working directories
3. **Profile Recognition**: Identifies user profiles from window titles and directories
4. **JSON Storage**: Saves session state in structured JSON format
5. **Reconstruction**: Recreates windows with the same profiles, positions, and directories

## Limitations

- Individual tab directory detection is limited by Linux process visibility
- Some manual setup may be needed for complex tab arrangements
- Sessions don't preserve command history or running processes

## Integration with Startup

To automatically restore your session on login:

1. Open System Settings → Startup and Shutdown → Autostart
2. Add a new application entry
3. Use command: `/home/user/git/dotfiles/konsoletabs/konsole-manager.sh restore`

## Troubleshooting

If windows don't position correctly:
- Check that KWin rules are properly configured
- Ensure display resolution matches the expected 3840x2050
- Run `konsole-manager.sh setup` to recreate the base layout

If directories aren't remembered:
- Use `save-adv` for better detection
- Check that the session JSON file contains correct working directories
- Verify that profiles are correctly identified
