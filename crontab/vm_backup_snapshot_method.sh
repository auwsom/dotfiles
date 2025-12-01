#!/bin/bash
# External snapshot method (more reliable)

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/snapshot-method-$(date +%Y%m%d-%H%M%S).qcow2"
SNAPSHOT_NAME="backup-snap-$(date +%s)"

echo "=== External Snapshot Backup Method ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"
echo "Snapshot: $SNAPSHOT_NAME"

mkdir -p "$DEST_DIR"

# Step 1: Create external snapshot (freezes the base)
echo "Step 1: Creating external snapshot..."
if timeout 10 virsh snapshot-create-as "$VM_NAME" "$SNAPSHOT_NAME" --disk-only --atomic; then
    echo "✓ Snapshot created"
    
    # Step 2: Copy the now-frozen base file
    echo "Step 2: Copying frozen base file..."
    if sudo cp "$SOURCE" "$BACKUP_FILE"; then
        echo "✓ Base backup created: $BACKUP_FILE"
        ls -lh "$BACKUP_FILE"
        
        # Step 3: Merge changes back
        echo "Step 3: Merging changes back..."
        if timeout 20 virsh blockcommit "$VM_NAME" vda --active --wait; then
            echo "✓ Changes merged successfully"
            
            # Step 4: Cleanup snapshot
            echo "Step 4: Cleaning up snapshot..."
            virsh snapshot-delete "$VM_NAME" "$SNAPSHOT_NAME" --metadata 2>/dev/null || true
            echo "✓ Cleanup completed"
            
            echo "🎉 SUCCESS: Backup completed!"
            exit 0
        else
            echo "❌ Step 3 failed: blockcommit"
        fi
    else
        echo "❌ Step 2 failed: copy base file"
    fi
else
    echo "❌ Step 1 failed: snapshot creation"
fi

exit 1
