#!/bin/bash
# vm_backup_nosudo.sh - Passwordless virsh backup

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="$1"
DEST_DIR="$2"
BACKUP_FILE="$DEST_DIR/$(basename "$SOURCE").$(date +%Y%m%d-%H%M%S).qcow2"

echo "Starting VM backup: $SOURCE -> $BACKUP_FILE"

# Ensure destination exists
mkdir -p "$DEST_DIR"

echo "Attempting blockcopy with 30s timeout (no sudo)..."
if timeout 30 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job 2>&1; then
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "SUCCESS: Backup created: $BACKUP_FILE"
        ls -lh "$BACKUP_FILE"
        exit 0
    else
        echo "WARNING: Command succeeded but file not created"
        exit 1
    fi
else
    echo "ERROR: Blockcopy failed or timed out"
    exit 1
fi
