#!/bin/bash
# Blockcopy test for pers VM (VM 11)

VM_ID="11"
VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
BACKUP_DIR="/media/user/backups/rtb-test"
BACKUP_FILE="$BACKUP_DIR/pers-blockcopy-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/pers-blockcopy-$(date +%s).log"

echo "=== Blockcopy Test for pers VM ==="
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

mkdir -p "$BACKUP_DIR"

echo "Starting blockcopy in background..."
timeout 5 nohup sudo virsh blockcopy "$VM_ID" vda "$BACKUP_FILE" --transient-job > "$LOGFILE" 2>&1 &
BACKUP_PID=$!

echo "Blockcopy started with PID: $BACKUP_PID"
echo "Monitor progress: tail -f $LOGFILE"
echo "Check file: ls -la $BACKUP_FILE"
echo "Expected size: ~22GB (similar to previous 22GB backup)"

echo "Blockcopy job submitted successfully!"
echo "Next step: Wait for completion, then mount and check for test file"
