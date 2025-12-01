#!/bin/bash
# VM backup with proper timeout (manual command takes ~15s to start)

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/final-test-$(date +%s).qcow2"

echo "=== VM Backup with 15s Timeout (matches manual timing) ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"

mkdir -p "$DEST_DIR"

# Use 15s timeout - matches how long you wait manually
echo "Executing: sudo timeout 15 virsh blockcopy $VM_NAME vda $BACKUP_FILE --transient-job"
sudo timeout 15 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job

EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"

if [[ $EXIT_CODE -eq 124 ]]; then
    echo "Timeout (124) - command took longer than 15 seconds"
elif [[ $EXIT_CODE -eq 0 ]]; then
    echo "Success (0) - check if file was created"
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "✓ Backup file created!"
        ls -lh "$BACKUP_FILE"
    else
        echo "⚠ Command succeeded but file not created (normal - blockcopy runs in background)"
    fi
else
    echo "Error ($EXIT_CODE) - command failed"
fi

echo "Backup started - file may be created in background"
