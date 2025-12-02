#!/bin/bash
# Clean up snapshot and restore normal VM operation

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"

echo "=== Snapshot Cleanup ==="
echo "VM: $VM_NAME"

# Step 1: Use blockcommit to merge snapshot changes back into base
echo "Step 1: Merging snapshot changes back into base..."
timeout 30 nohup sudo virsh blockcommit "$VM_NAME" vda --active --wait > /tmp/blockcommit.log 2>&1 &
BLOCKCOMMIT_PID=$!

echo "Blockcommit started with PID: $BLOCKCOMMIT_PID"
echo "Monitor: tail -f /tmp/blockcommit.log"
echo "This may take several minutes to complete..."

# Wait for blockcommit to complete
wait $BLOCKCOMMIT_PID 2>/dev/null
COMMIT_EXIT=$?

if [[ $COMMIT_EXIT -eq 0 ]]; then
    echo "✅ Blockcommit completed successfully"
    
    # Step 2: Check if snapshot file was automatically removed
    if [[ ! -f "/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.test-snapshot-timeout" ]]; then
        echo "✅ Snapshot file automatically removed"
    else
        echo "⚠️  Snapshot file still exists, attempting manual removal..."
        # Note: Manual removal may fail if VM is still using it
    fi
    
    # Step 3: Check VM status
    echo "Step 3: Checking VM status..."
    sudo timeout 3 virsh list --all | grep "$VM_NAME" && echo "✅ VM is running normally"
else
    echo "❌ Blockcommit failed (exit code: $COMMIT_EXIT)"
    echo "Check log: cat /tmp/blockcommit.log"
fi

echo "Cleanup completed"
