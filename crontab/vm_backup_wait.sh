#!/bin/bash
# Backup script that waits for file creation

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/wait-test-$(date +%s).qcow2"

echo "Starting backup with wait logic..."
echo "Backup file: $BACKUP_FILE"

mkdir -p "$DEST_DIR"

# Start blockcopy
echo "Starting blockcopy..."
if virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job; then
    echo "Blockcopy started successfully"
    
    # Wait for file to appear (up to 60 seconds)
    for i in {1..60}; do
        if [[ -f "$BACKUP_FILE" ]]; then
            echo "SUCCESS: Backup file created after $i seconds"
            ls -lh "$BACKUP_FILE"
            exit 0
        fi
        sleep 1
    done
    
    echo "TIMEOUT: File did not appear within 60 seconds"
else
    echo "ERROR: Blockcopy failed"
fi

exit 1
