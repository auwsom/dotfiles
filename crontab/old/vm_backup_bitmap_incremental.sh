#!/bin/bash
# QEMU Dirty Bitmap Incremental Backup - Native Method

VM_NAME="$1"           # VM name
SOURCE="$2"            # Source QCOW2 file path  
DEST_DIR="$3"          # Backup destination
BITMAP_NAME="backup-bitmap"
BACKUP_FILE="$DEST_DIR/incremental-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/bitmap-backup-$(date +%s).log"

echo "=== QEMU Dirty Bitmap Incremental Backup ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Bitmap: $BITMAP_NAME"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

mkdir -p "$DEST_DIR"

# Step 1: Start incremental backup using the bitmap
echo "Step 1: Starting incremental backup with bitmap..."
timeout 10 nohup sudo virsh qemu-monitor-command 11 '{"execute":"blockdev-backup","arguments":{"job-id":"backup-job","device":"libvirt-2-format","target":"'$BACKUP_FILE'","sync":"incremental","bitmap":"'$BITMAP_NAME'"}}' > "$LOGFILE" 2>&1 &
BACKUP_PID=$!

echo "Backup job started (PID: $BACKUP_PID)"
echo "Monitor job: tail -f $LOGFILE"

# Wait for backup to complete (this runs in background)
echo "Backup job submitted. Will run in background."
echo "Check status: virsh qemu-monitor-command 11 '{\"execute\":\"query-block-jobs\"}'"

# Store job info for monitoring
echo "$BACKUP_PID:$BACKUP_FILE:$LOGFILE" >> "/tmp/bitmap-backup-jobs.txt"

echo "Bitmap incremental backup started successfully!"
echo "Next step: After backup completes, clear/roll bitmap forward"
