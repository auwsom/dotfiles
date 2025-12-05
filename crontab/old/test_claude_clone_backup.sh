#!/bin/bash
# Test backup on claude-clone VM

VM_NAME="ubuntu20.04--set3--2404-upgrade--claude-clone"
SOURCE="/media/user/ai/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--kub-set3-2404--claude12backup-restored.qcow2"
DEST_DIR="/media/user/temp"
BACKUP_FILE="$DEST_DIR/claude-clone-backup-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/claude-backup-$(date +%s).log"

echo "=== Testing Claude Clone VM Backup ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

mkdir -p "$DEST_DIR"

# Use the proven working pattern
echo "Starting backup in background..."
timeout 5 nohup sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job > "$LOGFILE" 2>&1 &
BACKUP_PID=$!

echo "Backup started with PID: $BACKUP_PID"
echo "Monitor progress: tail -f $LOGFILE"
echo "Check file: ls -la $BACKUP_FILE"

# Store PID for monitoring
echo "$BACKUP_PID:$BACKUP_FILE:$LOGFILE:$VM_NAME" >> "/tmp/backup-pids.txt"

echo "Claude clone backup job submitted successfully!"
