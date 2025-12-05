#!/bin/bash
# Production virtnbdbackup automation - Weekly Full + Daily Incremental
# Based on extensive testing and proven success

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
BASE_BACKUP_DIR="/media/user/backups3/vm-backups" 
DATE=$(date +%Y%m%d)
DAY=$(date +%u)  # 1=Monday, 7=Sunday
RETENTION_DAYS=30

# Ensure backup directory exists
mkdir -p "$BASE_BACKUP_DIR"

# Weekly full on Sundays (7), daily incremental other days
if [ "$DAY" -eq 7 ]; then
    echo "=== WEEKLY FULL BACKUP: $DATE ==="
    BACKUP_TYPE="full"
    BACKUP_PATH="$BASE_BACKUP_DIR/week-$DATE-full"
else  
    echo "=== DAILY INCREMENTAL BACKUP: $DATE ==="
    BACKUP_TYPE="inc" 
    BACKUP_PATH="$BASE_BACKUP_DIR/week-${WEEK_NUM}-inc-$DATE"
    
    # Find latest weekly full backup for this week
    WEEK_NUM=$(date +%V)
    LATEST_FULL=$(find "$BASE_BACKUP_DIR" -name "week-$WEEK_NUM-full" -type d | head -1)
fi

echo "Backup Type: $BACKUP_TYPE"
echo "Target: $BACKUP_PATH" 

# Check for active block jobs and clear them if needed
echo "=== VERIFYING CLEAN VM STATE ==="
if sudo virsh domblkjob "$VM_NAME" vda 2>&1 | grep -q "active"; then
    echo "WARNING: Active block job detected, attempting to clear..."
    sudo timeout 10 virsh blockjob-cancel "$VM_NAME" vda
    sleep 3
fi

# Perform backup using stream format (proven efficient)
echo "=== STARTING $BACKUP_TYPE BACKUP ==="
sudo virtnbdbackup -d "$VM_NAME" -l "$BACKUP_TYPE" -t stream -o "$BACKUP_PATH"

BACKUP_EXIT=$?

if [ $BACKUP_EXIT -eq 0 ]; then
    echo "✅ $BACKUP_TYPE backup completed successfully"
    echo "Location: $BACKUP_PATH"
    
    # Calculate backup size for logging
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "Backup Size: $BACKUP_SIZE"
    
    # Retention policy (keep 4 weeks)
    echo "=== CLEANING UP OLD BACKUPS (>$RETENTION_DAYS days) ==="
    find "$BASE_BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec echo "Removing: {}" \;
    find "$BASE_BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null
else
    echo "❌ $BACKUP_TYPE backup failed with exit code: $BACKUP_EXIT"
    exit 1
fi

echo "=== VIRTNBDBACKUP COMPLETE ==="
