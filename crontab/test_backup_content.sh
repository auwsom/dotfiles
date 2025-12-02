#!/bin/bash
# Test if backup contains the test file

WEEKLY_BACKUP="/media/user/temp/claude-clone-backup-20251201-131732.qcow2"
TEST_FILE="test-1764623487"
MOUNT_POINT="/tmp/backup-test-$(date +%s)"

echo "=== Testing Backup Content ==="
echo "Backup file: $WEEKLY_BACKUP"
echo "Looking for test file: $TEST_FILE"
echo "Mount point: $MOUNT_POINT"

# Create mount point
mkdir -p "$MOUNT_POINT"

echo "=== Step 1: Connect backup via NBD ==="
sudo qemu-nbd --connect /dev/nbd0 "$WEEKLY_BACKUP"

echo "=== Step 2: Try to mount the filesystem ==="
# Try different mount approaches
echo "Attempting to mount /dev/nbd0p1..."
if sudo mount /dev/nbd0p1 "$MOUNT_POINT" 2>/dev/null; then
    echo "✅ Mounted successfully"
    echo "=== Step 3: Searching for test file ==="
    find "$MOUNT_POINT" -name "$TEST_FILE" 2>/dev/null && echo "✅ Test file found!" || echo "❌ Test file not found"
    
    echo "=== Step 4: Listing root directory ==="
    ls -la "$MOUNT_POINT" | head -10
    
    sudo umount "$MOUNT_POINT"
else
    echo "❌ Could not mount partition, trying direct filesystem check"
    echo "=== Step 3: Using guestfish to inspect ==="
    if command -v guestfish >/dev/null 2>&1; then
        guestfish --rw -a "$WEEKLY_BACKUP" -i find / -name "$TEST_FILE" 2>/dev/null && echo "✅ Found with guestfish!" || echo "❌ Not found with guestfish"
    else
        echo "guestfish not available"
    fi
fi

echo "=== Step 5: Cleanup ==="
sudo qemu-nbd --disconnect /dev/nbd0 2>/dev/null
rm -rf "$MOUNT_POINT"

echo "Backup content test completed"
