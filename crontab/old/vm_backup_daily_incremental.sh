#!/bin/bash
# Daily Incremental Backup Strategy - AI Confirmed Method

VM_NAME="$1"           # VM name
SOURCE="$2"            # Source QCOW2 file path  
DEST_DIR="$3"          # Backup destination
SNAPSHOT_NAME="daily-backup-$(date +%Y%m%d)"
BACKUP_FILE="$DEST_DIR/daily-$(date +%Y%m%d).qcow2"
LOGFILE="/tmp/daily-backup-$(date +%s).log"

echo "=== Daily Incremental Backup (AI Confirmed Method) ==="
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
    
    # Step 2: Backup the frozen base file
    echo "Step 2: Copying frozen base file..."
    sudo cp "$SOURCE" "$BACKUP_FILE"
    CP_EXIT=$?
    
    if [[ $CP_EXIT -eq 0 ]]; then
        echo "✅ Base file copied successfully"
        ls -lh "$BACKUP_FILE"
        
        # Step 3: Merge snapshot changes back into base
        echo "Step 3: Merging snapshot changes back..."
        timeout 30 nohup sudo virsh blockcommit "$VM_NAME" vda --active --wait >> "$LOGFILE" 2>&1 &
        COMMIT_PID=$!
        
        echo "Blockcommit started (PID: $COMMIT_PID)"
        wait $COMMIT_PID 2>/dev/null
        COMMIT_EXIT=$?
        
        if [[ $COMMIT_EXIT -eq 0 ]]; then
            echo "✅ Snapshot merged successfully"
            
            # Step 4: Clean up snapshot
            echo "Step 4: Cleaning up snapshot..."
            sudo virsh snapshot-delete "$VM_NAME" "$SNAPSHOT_NAME" --metadata 2>/dev/null
            echo "✅ Daily incremental backup completed!"
            
        else
            echo "❌ Blockcommit failed (exit: $COMMIT_EXIT)"
        fi
    else
        echo "❌ Base file copy failed (exit: $CP_EXIT)"
    fi
else
    echo "❌ Snapshot creation failed (exit: $SNAP_EXIT)"
    echo "Check log: cat $LOGFILE"
fi

echo "Daily backup process completed"
