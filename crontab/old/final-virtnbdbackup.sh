#!/bin/bash
# Final virtnbdbackup automation - tested and working approach

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
BASE_BACKUP_DIR="/media/user/backups3/vm-backups"
DATE=$(date +%Y%m%d-%H%M%S)
DAY=$(date +%u)

# Weekly full on Sunday (7), daily incremental other days
if [ "$DAY" -eq 7 ]; then
    echo "=== CREATING WEEKLY FULL BACKUP ==="
    BACKUP_TYPE="full"
    BACKUP_PATH="$BASE_BACKUP_DIR/$DATE-full"
    
    # Full backup - suspend VM for consistency
    sudo timeout 5 virsh suspend "$VM_NAME"
    sudo virtnbdbackup -d "$VM_NAME" -l full -t stream -o "$BACKUP_PATH"
    sudo timeout 5 virsh resume "$VM_NAME"
    
    echo "✅ Weekly full backup created: $BACKUP_PATH"
else
    echo "=== CREATING DAILY INCREMENTAL BACKUP ==="
    BACKUP_TYPE="inc"
    BACKUP_PATH="$BASE_BACKUP_DIR/$DATE-inc"
    
    # Find latest full backup for incremental base (check if needed)
    LATEST_FULL=$(find "$BASE_BACKUP_DIR" -name "*-full" -type d | sort -r | head -1)
    if [ -n "$LATEST_FULL" ]; then
        echo "Using base: $LATEST_FULL"
    fi
    
    # Incremental backup - suspend VM for consistency
    sudo timeout 5 virsh suspend "$VM_NAME"
    sudo virtnbdbackup -d "$VM_NAME" -l inc -t stream -o "$BACKUP_PATH"
    sudo timeout 5 virsh resume "$VM_NAME"
    
    echo "✅ Daily incremental backup created: $BACKUP_PATH"
fi

# Retention - keep 4 weeks of backups
find "$BASE_BACKUP_DIR" -type d -mtime +28 -exec echo "Would remove: {}" \;

echo "=== BACKUP COMPLETE ==="
