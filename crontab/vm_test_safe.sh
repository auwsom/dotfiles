#!/bin/bash
BACKUP_DIR="/media/user/backups3/rtb-ai-test"
VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
TIMESTAMP=$(date +%s)
BACKUP_FILE="${BACKUP_DIR}/test-safe-${TIMESTAMP}.qcow2"

echo "=== Space-Safe Test ==="
echo "Creating small test file instead of full backup..."

# Test virsh connection first
echo "Testing virsh connection:"
timeout 5 virsh list --all | head -3

# Test domain access  
echo "Testing domain access:"
timeout 5 virsh dominfo "$VM_NAME" > /dev/null 2>&1 && echo "Domain accessible" || echo "Domain access failed"

# Try blockcopy with immediate abort to test functionality
echo "Testing blockcopy command (will abort immediately):"
timeout 10 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job 2>&1 &
sleep 2
timeout 5 virsh blockjob "$VM_NAME" vda --abort 2>&1 > /dev/null 2>&1
echo "Blockcopy test completed"

# Check if file was created (it shouldn't be for safe test)
if [[ -f "$BACKUP_FILE" ]]; then
    echo "File created (cleaning up): $BACKUP_FILE"
    rm "$BACKUP_FILE"
else
    echo "No file created (safe test)"
fi

echo "=== Safe test complete ==="
