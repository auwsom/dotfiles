#!/bin/bash
# Backup script for 22GB VM

echo "=== Starting 22GB VM backup at $(date) ==="

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/22gb-vm-backup-$(date +%Y%m%d-%H%M%S).qcow2"

echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Destination: $DEST_DIR"

# Verify source exists
if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Source file not found: $SOURCE"
    exit 1
fi

echo "Source size: $(ls -lh "$SOURCE" | awk '{print $5}')"

mkdir -p "$DEST_DIR"

echo "Method 1: Direct blockcopy (15s timeout)..."
if timeout 15 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job; then
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
