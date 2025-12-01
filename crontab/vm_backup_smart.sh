#!/bin/bash
# VM Backup with Smart Retention - Working Method + Retention Logic

VM_NAME="$1"           # VM name (e.g., ubuntu20.04-kvm-img--mini--set2--kub--pers)
SOURCE="$2"            # Source QCOW2 file path
DEST_DIR="$3"          # Backup destination directory
STRATEGY="$4"          # Retention strategy (e.g., "3:1 4:7 30:7")
BACKUP_FILE="$DEST_DIR/vm-backup-$(date +%Y%m%d-%H%M%S).qcow2"
LOGFILE="/tmp/vm-backup-$(date +%s).log"

# Function to apply retention strategy
fn_apply_retention() {
    local dest_dir="$1"
    local strategy="$2"
    
    echo "Applying retention strategy: $strategy"
    
    # Parse strategy (e.g., "3:1 4:7 30:7")
    IFS=' ' read -ra RULES <<< "$strategy"
    
    for rule in "${RULES[@]}"; do
        IFS=':' read -r DAYS INTERVAL <<< "$rule"
        
        echo "Rule: After $DAYS days, keep 1 every $INTERVAL days"
        
        # Find files older than $DAYS days and apply retention
        find "$dest_dir" -name "vm-backup-*.qcow2" -type f -mtime +$DAYS -printf "%T@ %p\n" | \
        sort -rn | \
        awk -v interval="$INTERVAL" '
        NR == 1 { first_time = $1; count = 0 }
        {
            if (int((first_time - $1) / 86400) >= (count * interval)) {
                count++
                next
            }
            print "Would delete: " $2
        }' | \
        while read -r file; do
            echo "Deleting old backup: $file"
            rm -f "$file"
        done
    done
}

echo "=== VM Smart Backup ==="
echo "VM: $VM_NAME"
echo "Source: $SOURCE"
echo "Destination: $DEST_DIR"
echo "Strategy: $STRATEGY"
echo "Backup: $BACKUP_FILE"
echo "Log: $LOGFILE"

# Create destination directory
mkdir -p "$DEST_DIR"

# Apply retention before new backup
fn_apply_retention "$DEST_DIR" "$STRATEGY"

# Use the proven working pattern: timeout 5 nohup sudo virsh & 
echo "Starting backup in background..."
timeout 5 nohup sudo virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job > "$LOGFILE" 2>&1 &
BACKUP_PID=$!

echo "Backup started with PID: $BACKUP_PID"
echo "Monitor progress: tail -f $LOGFILE"
echo "Check file: ls -la $BACKUP_FILE"

# Store PID for monitoring
echo "$BACKUP_PID:$BACKUP_FILE:$LOGFILE:$VM_NAME" >> "/tmp/backup-pids.txt"

echo "Smart backup job submitted successfully!"
