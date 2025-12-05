#!/bin/bash
# VM Smart Backup with virtnbdbackup - Full/Incremental with Merging
# Replaces rsync_tmbackup3.sh for QCOW2 files
# Usage: virtnbdbackup_plus.sh -s SOURCE -d DEST [--full-day DAY] [--vm-name NAME]

set -e

# Defaults
FULL_DAY="7"  # Sunday (7) for weekly full backup
VM_NAME=""
BACKUP_SOURCE=""
BACKUP_DEST=""
DAY_OF_WEEK=$(date +%u)
DATE=$(date +%Y%m%d)
WEEK_NUM=$(date +%V)

# Parse arguments (mimic rsync_tmbackup3.sh interface)
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            BACKUP_SOURCE="$2"
            shift 2
            ;;
        -d|--dest)
            BACKUP_DEST="$2"
            shift 2
            ;;
        --vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        --full-day)
            FULL_DAY="$2"
            shift 2
            ;;
        --strategy)
            echo "Info: Retention strategy ignored for VM backups (using virtnbdbackup chain)"
            shift 2
            ;;
        --prune-then-backup)
            echo "Info: Auto-prune enabled (keeping 4 weeks)"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            shift
            ;;
    esac
done

# Validate required args
if [[ -z "$BACKUP_SOURCE" || -z "$BACKUP_DEST" ]]; then
    echo "Usage: $0 -s SOURCE -d DEST [--full-day DAY] [--vm-name NAME]"
    echo "  -s, --source      QCOW2 file path"
    echo "  -d, --dest        Backup destination directory"
    echo "  --vm-name         VM name (if different from QCOW2 filename)"
    echo "  --full-day        Day for weekly full backup (1-7, default: 7)"
    exit 1
fi

# Auto-detect VM name from QCOW2 filename if not provided
if [[ -z "$VM_NAME" ]]; then
    QCOW2_BASENAME=$(basename "$BACKUP_SOURCE")
    VM_NAME="${QCOW2_BASENAME%.*}"
    echo "Auto-detected VM name: $VM_NAME"
fi

# Create destination directory
mkdir -p "$BACKUP_DEST"

# Determine backup type (weekly full or daily incremental)
BACKUP_TYPE="inc"
BACKUP_PATH="$BACKUP_DEST/week-${WEEK_NUM}-inc-${DATE}"
LAST_FULL="$(find "$BACKUP_DEST" -name "week-${WEEK_NUM}-full" -type d | head -1)"

if [[ "$DAY_OF_WEEK" == "$FULL_DAY" || -z "$LAST_FULL" ]]; then
    BACKUP_TYPE="full"
    BACKUP_PATH="$BACKUP_DEST/week-${WEEK_NUM}-full"
    echo "=== WEEKLY FULL BACKUP (Day $FULL_DAY) ==="
else
    echo "=== DAILY INCREMENTAL BACKUP ==="
fi

echo "Source: $BACKUP_SOURCE"
echo "Destination: $BACKUP_DEST"
echo "VM: $VM_NAME"  
echo "Backup Type: $BACKUP_TYPE"
echo "Backup Path: $BACKUP_PATH"

# Check for active block jobs
if sudo virsh domblkjob "$VM_NAME" vda 2>&1 | grep -q "active"; then
    echo "WARNING: Active block job detected, attempting to clear..."
    sudo timeout 10 virsh blockjob-cancel "$VM_NAME" vda >/dev/null 2>&1 || true
    sleep 3
fi

# Perform backup
if [[ "$BACKUP_TYPE" == "full" ]]; then
    echo "=== CREATING FULL BACKUP ==="
    sudo virtnbdbackup -d "$VM_NAME" -l full -o "$BACKUP_PATH"
else
    echo "=== CREATING INCREMENTAL BACKUP ==="
    if [[ -d "$LAST_FULL" ]]; then
        sudo virtnbdbackup -d "$VM_NAME" -l inc -o "$LAST_FULL"
        echo "Incremental added to chain starting from: $LAST_FULL"
    else
        echo "ERROR: No full backup found for week $WEEK_NUM, falling back to full backup"
        BACKUP_PATH="$BACKUP_DEST/week-${WEEK_NUM}-full"
        sudo virtnbdbackup -d "$VM_NAME" -l full -o "$BACKUP_PATH"
    fi
fi

if [[ $? -eq 0 ]]; then
    echo "✅ Backup completed successfully"
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo "Backup Size: $BACKUP_SIZE"
    
    # Retention (keep 4 weeks = 28 days + buffer)
    echo "=== APPLYING RETENTION POLICY (30 days) ==="
    find "$BACKUP_DEST" -type d -mtime +30 -exec echo "Removing old backup: {}" \;
    find "$BACKUP_DEST" -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null
else
    echo "❌ Backup failed"
    exit 1
fi

echo "=== BACKUP COMPLETE ==="
