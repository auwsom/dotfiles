#!/bin/bash
# Automated Weekly Full + Daily Incremental virtnbdbackup Script
# Based on extensive testing and proven methods

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
BACKUP_DIR="/media/user/backups/vm-backups"
DATE=$(date +%Y%m%d)
DAY=$(date +%u)  # 1=Monday, 7=Sunday
RETENTION_DAYS=28

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Weekly full on Sundays, daily incremental other days
if [ "$DAY" -eq 7 ]; then
    echo "=== WEEKLY FULL BACKUP: $DATE ==="
    BACKUP_TYPE="full"
    BACKUP_PATH="$BACKUP_DIR/$DATE-full"
else  
    echo "=== DAILY INCREMENTAL BACKUP: $DATE ==="
    BACKUP_TYPE="inc"
    BACKUP_PATH="$BACKUP_DIR/$DATE-inc"
fi

# Create backup with VM suspension for consistency
echo "Suspending VM..."
sudo virsh suspend "$VM_NAME"
echo "Starting $BACKUP_TYPE backup..."

# Use stream format for efficiency (skips zero blocks)
sudo virtnbdbackup -d "$VM_NAME" -l "$BACKUP_TYPE" -t stream -o "$BACKUP_PATH"

BACKUP_EXIT=$?

# Always resume VM even if backup fails
echo "Resuming VM..."
sudo virsh resume "$VM_NAME"

if [ $BACKUP_EXIT -eq 0 ]; then
    echo "✅ $BACKUP_TYPE backup completed successfully"
    echo "Backup location: $BACKUP_PATH"
    
    # Retention: Remove backups older than retention period
    echo "=== CLEANING UP OLD BACKUPS (>$RETENTION_DAYS days) ==="
    find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null
    echo "✅ Retention cleanup completed"
else
    echo "❌ $BACKUP_TYPE backup failed with exit code: $BACKUP_EXIT"
    exit 1
fi

echo "=== BACKUP COMPLETE ==="
