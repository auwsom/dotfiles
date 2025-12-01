#!/bin/bash
# Backup with correct file path

echo "=== Starting backup at $(date) ==="

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/user/ai/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--kub-set3-2404--claude12-display.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/backup-$(date +%Y%m%d-%H%M%S).qcow2"

echo "Source: $SOURCE"
echo "Destination: $DEST_DIR"

# Verify source exists
if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE"
    exit 1
fi

mkdir -p "$DEST_DIR"

echo "Method 1: Direct blockcopy (10s timeout)..."
if timeout 10 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job; then
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "SUCCESS: Blockcopy worked!"
        ls -lh "$BACKUP_FILE"
        exit 0
    else
        echo "Blockcopy succeeded but file not created"
    fi
else
    echo "Blockcopy timed out/failed (exit: $?)"
fi

echo "Backup attempt completed"
