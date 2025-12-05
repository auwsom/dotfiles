#!/bin/bash
# VM backup with sudo timeout 5 (from notes)

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/timeout-test-$(date +%s).qcow2"

echo "=== VM Backup with Sudo Timeout 5 ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"

mkdir -p "$DEST_DIR"

# Use sudo timeout 5 as per notes
echo "Executing: sudo timeout 5 virsh blockcopy $VM_NAME vda $BACKUP_FILE --transient-job"
sudo timeout 5 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job

EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"

if [[ $EXIT_CODE -eq 124 ]]; then
    echo "Timeout (124) - command took longer than 5 seconds"
elif [[ $EXIT_CODE -eq 0 ]]; then
    echo "Success (0) - check if file was created"
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "✓ Backup file created!"
        ls -lh "$BACKUP_FILE"
    else
        echo "⚠ Command succeeded but file not created"
    fi
else
    echo "Error ($EXIT_CODE) - command failed"
fi

echo "Backup test completed"
