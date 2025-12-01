#!/bin/bash

# Enhanced debugging wrapper for rtb_smart_backups.sh
LOGFILE="/home/user/backup_debug_$(date +%Y%m%d_%H%M%S).log"
BACKUP_SCRIPT="/home/user/dotfiles/crontab/rtb_smart_backups.sh"
RSYNC_LOG_DIR="/root/.rsync-time-backup"

echo "=== Backup Debug Session Started: $(date) ===" > "$LOGFILE"
echo "User: $(whoami)" >> "$LOGFILE"
echo "PID: $$" >> "$LOGFILE"
echo "Script: $BACKUP_SCRIPT" >> "$LOGFILE"
echo "Working Dir: $(pwd)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Check environment
echo "=== Environment Variables ===" >> "$LOGFILE"
env | grep -E "(BACKUP|RSYNC|CRON)" >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check script permissions
echo "=== Script Permissions ===" >> "$LOGFILE"
ls -la "$BACKUP_SCRIPT" >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check if backup script exists and is executable
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "ERROR: Backup script not found: $BACKUP_SCRIPT" >> "$LOGFILE"
    exit 1
fi

if [ ! -x "$BACKUP_SCRIPT" ]; then
    echo "ERROR: Backup script not executable: $BACKUP_SCRIPT" >> "$LOGFILE"
    exit 1
fi

# Check disk space before backup
echo "=== Disk Space Before ===" >> "$LOGFILE"
df -h /media/user/backups* >> "$LOGFILE" 2>&1
df -i /media/user/backups* >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check for in_progress files before
echo "=== In_progress Files Before ===" >> "$LOGFILE"
find /media/user/backups* -name "in_progress" 2>/dev/null >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check rsync log directory
echo "=== Rsync Log Directory ===" >> "$LOGFILE"
ls -la "$RSYNC_LOG_DIR/" >> "$LOGFILE" 2>&1
echo "Rsync log dir ownership: $(sudo stat -c '%U:%G' $RSYNC_LOG_DIR 2>/dev/null || echo 'Cannot access')" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Check source directories exist
echo "=== Source Directory Checks ===" >> "$LOGFILE"
echo "USB source: /media/user/16GBa - $(ls -la /media/user/16GBa 2>&1 | head -1)" >> "$LOGFILE"
echo "Home source: /home/user - $(ls -la /home/user 2>&1 | head -1)" >> "$LOGFILE"
echo "VM source: /media/user/VM - $(ls -la /media/user/VM 2>&1 | head -1)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Check destination directories
echo "=== Destination Directory Checks ===" >> "$LOGFILE"
find /media/user/backups* -maxdepth 1 -type d -name "rtb-*" >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Run the actual backup script with all output captured
echo "=== Running Backup Script ===" >> "$LOGFILE"
echo "Command: $BACKUP_SCRIPT" >> "$LOGFILE"
echo "Start time: $(date)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Execute backup script and capture all output with timing
start_time=$(date +%s)
"$BACKUP_SCRIPT" >> "$LOGFILE" 2>&1
EXIT_CODE=$?
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" >> "$LOGFILE"
echo "=== Backup Script Completed ===" >> "$LOGFILE"
echo "Exit Code: $EXIT_CODE" >> "$LOGFILE"
echo "Duration: $duration seconds" >> "$LOGFILE"
echo "End time: $(date)" >> "$LOGFILE"

# Check disk space after backup
echo "" >> "$LOGFILE"
echo "=== Disk Space After ===" >> "$LOGFILE"
df -h /media/user/backups* >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check for in_progress files after
echo "=== In_progress Files After ===" >> "$LOGFILE"
find /media/user/backups* -name "in_progress" 2>/dev/null >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check if any new backups were created
echo "=== New Backup Directories ===" >> "$LOGFILE"
TODAY=$(date +%Y-%m-%d)
find /media/user/backups* -maxdepth 2 -name "${TODAY}*" -type d 2>/dev/null >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check rsync log files created during backup
echo "=== New Rsync Log Files ===" >> "$LOGFILE"
find "$RSYNC_LOG_DIR" -name "*$(date +%Y%m%d)*" -type f 2>/dev/null >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# If rsync logs exist, try to show their contents
echo "=== Rsync Log Contents ===" >> "$LOGFILE"
find "$RSYNC_LOG_DIR" -name "*$(date +%Y%m%d)*" -type f -exec echo "=== {} ===" \; -exec cat {} \; 2>/dev/null >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

# Check for any error patterns in the log
echo "=== Error Pattern Analysis ===" >> "$LOGFILE"
grep -i "error\|warning\|failed\|abort" "$LOGFILE" | tail -10 >> "$LOGFILE" 2>&1
echo "" >> "$LOGFILE"

echo "=== Debug Session Complete ===" >> "$LOGFILE"

# Exit with same code as backup script
exit $EXIT_CODE
