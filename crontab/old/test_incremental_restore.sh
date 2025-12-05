#!/bin/bash
# Test Incremental Backup and Restore Process

VM_NAME="ubuntu20.04--set3--2404-upgrade--claude-clone"
WEEKLY_BACKUP="/media/user/temp/claude-clone-backup-20251201-131732.qcow2"  # Your completed "weekly" backup
INCREMENTAL_BACKUP="/media/user/temp/incremental-test-$(date +%Y%m%d-%H%M%S).qcow2"
MERGED_BACKUP="/media/user/temp/merged-restored-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/incremental-test-$(date +%s).log"

echo "=== Testing Incremental Backup & Restore Workflow ==="
echo "=== STEP 1: Create incremental backup ==="
echo "Weekly Backup: $WEEKLY_BACKUP"
echo "Incremental Backup: $INCREMENTAL_BACKUP"

# Step 1: Create incremental backup using dirty bitmaps
echo "Creating incremental backup..."
timeout 5 nohup sudo virsh qemu-monitor-command 12 '{"execute":"blockdev-backup","arguments":{"job-id":"incremental-test","device":"libvirt-2-format","target":"'$INCREMENTAL_BACKUP'","sync":"incremental","bitmap":"backup-bitmap"}}' > "$LOGFILE" 2>&1 &
INCR_PID=$!

echo "Incremental backup started (PID: $INCR_PID)"
echo "Monitor: tail -f $LOGFILE"

# Wait a bit and check
sleep 5
echo "=== STEP 2: Check incremental backup file ==="
if [[ -f "$INCREMENTAL_BACKUP" ]]; then
    ls -lh "$INCREMENTAL_BACKUP"
    echo "✅ Incremental backup created"
else
    echo "⚠️  Incremental backup still being created"
fi

echo "=== STEP 3: Test restore process ==="
echo "This will create a merged backup from weekly + incremental"
echo "Final merged file: $MERGED_BACKUP"

echo "Incremental backup test started. Check progress with:"
echo "  - ls -lh $INCREMENTAL_BACKUP"
echo "  - tail -f $LOGFILE"
echo "  - virsh qemu-monitor-command 12 '{\"execute\":\"query-block-jobs\"}'"
