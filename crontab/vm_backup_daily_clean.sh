#!/bin/bash
# Clean Daily Incremental Backup - External Snapshot Method with Immediate Cleanup

VM_NAME="$1"           # VM name
SOURCE="$2"            # Source QCOW2 file path  
DEST_DIR="$3"          # Backup destination
SNAPSHOT_NAME="daily-$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="$DEST_DIR/daily-$(date +%Y%m%d_%H%M%S).qcow2"
LOGFILE="/tmp/daily-clean-backup-$(date +%s).log"

echo "=== Clean Daily Incremental Backup ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Snapshot: $SNAPSHOT_NAME"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

mkdir -p "$DEST_DIR"

# Step 1: Create external snapshot (freezes base for backup)
echo "Step 1: Creating external snapshot..."
timeout 10 nohup sudo virsh snapshot-create-as "$VM_NAME" "$SNAPSHOT_NAME" --disk-only > "$LOGFILE" 2>&1 &
SNAP_PID=$!

echo "Snapshot creation started (PID: $SNAP_PID)"
wait $SNAP_PID 2>/dev/null
SNAP_EXIT=$?

if [[ $SNAP_EXIT -eq 0 ]]; then
    echo "✅ Snapshot created successfully"
    
    # Step 2: Backup the frozen base file (fast and consistent)
    echo "Step 2: Copying frozen base file..."
    sudo cp "$SOURCE" "$BACKUP_FILE"
    CP_EXIT=$?
    
    if [[ $CP_EXIT -eq 0 ]]; then
        echo "✅ Base file copied successfully"
        ls -lh "$BACKUP_FILE"
        
        # Step 3: IMMEDIATELY merge snapshot changes back into base (key cleanup)
        echo "Step 3: Merging snapshot changes back into base..."
        timeout 30 nohup sudo virsh blockcommit "$VM_NAME" vda --active --wait >> "$LOGFILE" 2>&1 &
        COMMIT_PID=$!
        
        echo "Blockcommit started (PID: $COMMIT_PID)"
        wait $COMMIT_PID 2>/dev/null
        COMMIT_EXIT=$?
        
        if [[ $COMMIT_EXIT -eq 0 ]]; then
            echo "✅ Snapshot merged successfully"
            
            # Step 4: Clean up snapshot metadata
            echo "Step 4: Cleaning up snapshot metadata..."
            timeout 5 nohup sudo virsh snapshot-delete "$VM_NAME" "$SNAPSHOT_NAME" --metadata >> "$LOGFILE" 2>&1 &
            echo "✅ Daily incremental backup completed!"
            
            echo "📊 Backup Info:"
            echo "  - File: $BACKUP_FILE"
            echo "  - Size: $(ls -lh $BACKUP_FILE | awk '{print $5}')"
            echo "  - VM is now back to normal operation"
            
        else
            echo "❌ Blockcommit failed (exit: $COMMIT_EXIT)"
            echo "⚠️  VM may still be in snapshot mode - requires manual intervention"
        fi
    else
        echo "❌ Base file copy failed (exit: $CP_EXIT)"
        echo "⚠️  Attempting to merge snapshot anyway to restore VM..."
        timeout 30 nohup sudo virsh blockcommit "$VM_NAME" vda --active --wait >> "$LOGFILE" 2>&1 &
    fi
else
    echo "❌ Snapshot creation failed (exit: $SNAP_EXIT)"
    echo "Check log: cat $LOGFILE"
fi

echo "Daily backup process completed"
