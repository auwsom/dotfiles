#!/bin/bash
echo "=== Testing backup with fixed libvirt ==="

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/final-test-$(date +%s).qcow2"

echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Dest: $DEST_DIR"

sudo mkdir -p "$DEST_DIR"
sudo chmod 755 "$DEST_DIR"

echo "Method 1: Blockcopy with 15s timeout..."
if timeout 15 sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job; then
    echo "Blockcopy command exit: $?"
    if sudo ls -la "$BACKUP_FILE" 2>/dev/null; then
        echo "SUCCESS: Backup created!"
        exit 0
    else
        echo "Command succeeded but file not found"
    fi
else
    echo "Blockcopy timed out (exit: $?)"
fi

echo "Backup test completed"
