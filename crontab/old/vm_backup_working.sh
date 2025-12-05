#!/bin/bash
# VM Backup Script - Working Method (timeout 5 nohup &)

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
SOURCE="/media/veracrypt5/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--mini--set2-lp-tw-15G--kub-12G-sparse-convertcopyshrunk2.qcow2"
DEST_DIR="$1"
BACKUP_FILE="$DEST_DIR/working-backup-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/backup-$(date +%s).log"

echo "=== VM Backup - Working Method ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

# Create destination directory
mkdir -p "$DEST_DIR"

# Use the proven working pattern: timeout 5 nohup sudo virsh & 
echo "Starting backup in background..."
timeout 5 nohup sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job > "$LOGFILE" 2>&1 &
BACKUP_PID=$!

echo "Backup started with PID: $BACKUP_PID"
echo "Monitor progress: tail -f $LOGFILE"
echo "Check file: ls -la $BACKUP_FILE"

# Store PID for monitoring
echo "$BACKUP_PID:$BACKUP_FILE:$LOGFILE" >> "/tmp/backup-pids.txt"

echo "Backup job submitted successfully!"
