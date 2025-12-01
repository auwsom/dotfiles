#!/bin/bash
# Exact match of working manual command

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/exact-match-$(date +%s).qcow2"

sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job

# Check if file was created
if [[ -f "$BACKUP_FILE" ]]; then
    echo "SUCCESS: Backup created: $BACKUP_FILE"
    ls -lh "$BACKUP_FILE"
else
    echo "File not created yet (blockcopy runs in background)"
fi
