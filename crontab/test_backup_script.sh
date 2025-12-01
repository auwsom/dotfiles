#!/bin/bash
echo "=== Backup Test Script ==="
echo "Testing on: $(date)"

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/user/ai/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--kub-set3-2404--claude12.qcow2"
DEST_DIR="/media/user/backups3/rtb-ai-test/"
BACKUP_FILE="$DEST_DIR/test-backup.$(date +%Y%m%d-%H%M%S).qcow2"

# Test 1: Check if VM exists
echo "1. Checking VM status..."
virsh dominfo "$VM_NAME" | head -3

# Test 2: Create backup directory if needed
echo "2. Creating destination..."
mkdir -p "$DEST_DIR"

# Test 3: Try blockcopy with feedback
echo "3. Starting blockcopy to: $BACKUP_FILE"
echo "   Command: virsh blockcopy $VM_NAME vda $BACKUP_FILE --transient-job"

# Run in background with immediate feedback
virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job &
BLOCKCOPY_PID=$!
echo "   Process started: PID $BLOCKCOPY_PID"

# Give it 10 seconds to show progress
echo "   Waiting 10 seconds..."
sleep 10

# Check if process is still running and if file was created
if ps -p $BLOCKCOPY_PID >/dev/null; then
    echo "   Blockcopy still running..."
    ls -la "$BACKUP_FILE" 2>/dev/null && echo "   ✓ File is being created" || echo "   ✗ No file yet"
else
    echo "   Blockcopy completed"
    ls -lh "$BACKUP_FILE" && echo "   ✓ Backup created successfully" || echo "   ✗ Backup failed"
fi

echo "=== Test complete ==="
