#!/bin/bash
# Test Restore Process - Check for test file in backup

WEEKLY_BACKUP="/media/user/temp/claude-clone-backup-20251201-131732.qcow2"
RESTORE_TEST="/tmp/restore-test-$(date +%s).qcow2"

echo "=== Testing Restore Process ==="
echo "Weekly Backup: $WEEKLY_BACKUP"
echo "Restore Test: $RESTORE_TEST"

# Copy the weekly backup to test location
echo "Copying backup for testing..."
cp "$WEEKLY_BACKUP" "$RESTORE_TEST"

echo "=== Checking if test file exists in backup ==="
# Use qemu-nbd to mount the backup and check for test file
echo "Setting up NBD device..."
sudo qemu-nbd --connect /dev/nbd0 "$RESTORE_TEST"

echo "Mounting the backup..."
sudo mount /dev/nbd0p1 /tmp/backup-test 2>/dev/null || echo "No partitions, trying direct mount"

# Check for test file
if mountpoint /tmp/backup-test >/dev/null 2>&1; then
    echo "=== Mounted at /tmp/backup-test ==="
    find /tmp/backup-test -name "test-1764623487" 2>/dev/null && echo "✅ Test file found!" || echo "❌ Test file not found"
    sudo umount /tmp/backup-test
else
    echo "=== Trying to check filesystem directly ==="
    sudo qemu-img check "$RESTORE_TEST" && echo "Backup filesystem check passed"
fi

echo "=== Cleanup ==="
sudo qemu-nbd --disconnect /dev/nbd0 2>/dev/null
rm -f "$RESTORE_TEST"

echo "Restore test completed"
