#!/bin/bash
# Simple backup with immediate feedback

echo "=== Starting backup at $(date) ==="

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="$1"  
DEST_DIR="$2"
BACKUP_FILE="$DEST_DIR/test-$(date +%s).qcow2"

mkdir -p "$DEST_DIR"

echo "Method 1: Trying direct blockcopy..."
timeout 10 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job
echo "Exit code: $?"

if [[ -f "$BACKUP_FILE" ]]; then
    echo "SUCCESS: File created!"
    ls -lh "$BACKUP_FILE"
    exit 0
fi

echo "Method 2: Trying external snapshot..."
SNAP_NAME="test-snap-$(date +%s)"

echo "Creating snapshot..."
timeout 10 virsh snapshot-create-as "$VM_NAME" "$SNAP_NAME" --disk-only
echo "Snapshot exit: $?"

if [[ $? -eq 0 ]]; then
    echo "Copying base file..."
    cp "$SOURCE" "$BACKUP_FILE"
    echo "Copy exit: $?"
    
    echo "Merging changes..."
    timeout 10 virsh blockcommit "$VM_NAME" vda --active --wait
    echo "Merge exit: $?"
    
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "SUCCESS: Snapshot backup created!"
        ls -lh "$BACKUP_FILE"
        # Cleanup
        virsh snapshot-delete "$VM_NAME" "$SNAP_NAME" --metadata 2>/dev/null || echo "Cleanup failed"
        exit 0
    fi
fi

echo "All methods failed"
exit 1
