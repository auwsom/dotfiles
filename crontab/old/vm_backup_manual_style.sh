#!/bin/bash
# VM backup - exact manual style (no timeout, background process)

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/manual-style-$(date +%s).qcow2"

echo "=== VM Backup - Manual Style (No Timeout) ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"

mkdir -p "$DEST_DIR"

# Exact command you use manually - no timeout
echo "Executing: sudo virsh blockcopy $VM_NAME vda $BACKUP_FILE --transient-job"
sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job

EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✓ Blockcopy started successfully"
    echo "Backup will run in background"
    echo "Check file creation later with: ls -la $BACKUP_FILE"
elif [[ $EXIT_CODE -eq 124 ]]; then
    echo "ERROR: Should not timeout with manual style"
else
    echo "ERROR: Command failed with code $EXIT_CODE"
fi

echo "Backup command completed"
