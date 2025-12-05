#!/bin/bash
# Mount backup and check for test files

BACKUP_FILE="/media/user/backups/rtb-test/manual-blockcopy-20251201-144836.qcow2"
MOUNT_POINT="/tmp/backup-mount-$(date +%s)"

echo "=== Mounting Backup to Check Test Files ==="
echo "Backup: $BACKUP_FILE"
echo "Mount: $MOUNT_POINT"

mkdir -p "$MOUNT_POINT"

echo "Step 1: Connect via NBD..."
sudo qemu-nbd --connect /dev/nbd0 "$BACKUP_FILE"

echo "Step 2: Try mounting..."
if sudo mount /dev/nbd0p1 "$MOUNT_POINT" 2>/dev/null; then
    echo "✅ Mounted successfully"
    echo "Step 3: Looking for test files..."
    find "$MOUNT_POINT" -name "test*" -o -name "*test*" 2>/dev/null | head -10
    echo "Step 4: Root directory contents:"
    ls -la "$MOUNT_POINT" | head -10
    sudo umount "$MOUNT_POINT"
else
    echo "❌ Could not mount, trying filesystem check..."
    sudo qemu-img check "$BACKUP_FILE" && echo "✅ Filesystem check passed"
fi

echo "Step 5: Cleanup..."
sudo qemu-nbd --disconnect /dev/nbd0 2>/dev/null
rm -rf "$MOUNT_POINT"

echo "Mount and check completed"
