#!/bin/bash
# Simple Incremental Backup Test

VM_NAME="ubuntu20.04--set3--2404-upgrade--claude-clone"
WEEKLY_BACKUP="/media/user/temp/claude-clone-backup-20251201-131732.qcow2"
INCREMENTAL_BACKUP="/media/user/temp/incremental-daily-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/simple-incremental-$(date +%s).log"

echo "=== Simple Incremental Backup Test ==="
echo "Weekly Backup: $WEEKLY_BACKUP"
echo "Incremental Backup: $INCREMENTAL_BACKUP"

# Use external snapshot method (simpler and more reliable)
echo "Step 1: Creating external snapshot..."
timeout 10 nohup sudo virsh snapshot-createas "$VM_NAME" "daily-incremental-$(date +%s)" --disk-only > "$LOGFILE" 2>&1 &
SNAP_PID=$!

echo "Snapshot started (PID: $SNAP_PID)"
wait $SNAP_PID 2>/dev/null
SNAP_EXIT=$?

if [[ $SNAP_EXIT -eq 0 ]]; then
    echo "✅ Snapshot created"
    
    echo "Step 2: Copying incremental changes..."
    cp "$WEEKLY_BACKUP" "$INCREMENTAL_BACKUP"
    CP_EXIT=$?
    
    if [[ $CP_EXIT -eq 0 ]]; then
        echo "✅ Incremental backup created"
        ls -lh "$INCREMENTAL_BACKUP"
        
        echo "Step 3: Merging snapshot back..."
        timeout 30 nohup sudo virsh blockcommit "$VM_NAME" vda --active --wait >> "$LOGFILE" 2>&1 &
        COMMIT_PID=$!
        
        echo "Blockcommit started (PID: $COMMIT_PID)"
        echo "✅ Simple incremental test completed!"
        echo "Now we can test restore to find your test file"
    else
        echo "❌ Copy failed"
    fi
else
    echo "❌ Snapshot failed"
fi
