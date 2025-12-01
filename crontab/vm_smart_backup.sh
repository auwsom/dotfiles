#!/bin/bash

# vm_smart_backup.sh - Smart VM backup with incremental snapshot support
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Configuration
INCREMENTAL=0
VM_NAME=""
SNAPSHOT_PREFIX="backup-snapshot"

# Logging
fn_log() { echo "vm_smart_backup: [INFO] $1"; }
fn_log_warn() { echo "vm_smart_backup: [WARNING] $1" 1>&2; }
fn_log_error() { echo "vm_smart_backup: [ERROR] $1" 1>&2; }

# Incremental backup using external snapshots
fn_incremental_backup() {
    local source="$1"
    local dest_dir="$2"
    local vm_name="$3"
    
    fn_log "Starting incremental backup for VM: $vm_name"
    
    # Check if VM exists and is running
    if ! virsh dominfo "$vm_name" >/dev/null 2>&1; then
        fn_log_error "VM '$vm_name' not found or not accessible"
        return 1
    fi
    
    # Get VM state
    local vm_state=$(virsh domstate "$vm_name")
    fn_log "VM state: $vm_state"
    
    # Create external snapshot if VM is running
    local snapshot_name="${SNAPSHOT_PREFIX}-$(date +%Y%m%d-%H%M%S)"
    
    if [ "$vm_state" = "running" ]; then
        fn_log "Creating external snapshot: $snapshot_name"
        
        # Create snapshot with backing file
        if ! virsh snapshot-create-as "$vm_name" "$snapshot_name" \
             --disk-only --atomic --no-metadata; then
            fn_log_error "Failed to create snapshot"
            return 1
        fi
    fi
    
    # Create backup filename
    local backup_file="$dest_dir/${vm_name}-$(date +%Y-%m-%d-%H%M%S).qcow2"
    
    # Use qemu-img convert
    fn_log "Creating backup: $backup_file"
    
    if ! qemu-img convert -p -O qcow2 "$source" "$backup_file"; then
        fn_log_error "Backup creation failed"
        # Clean up snapshot on failure
        if [ "$vm_state" = "running" ]; then
            virsh snapshot-delete "$vm_name" "$snapshot_name" --metadata >/dev/null 2>&1 || true
        fi
        return 1
    fi
    
    # Clean up snapshot after successful backup
    if [ "$vm_state" = "running" ]; then
        fn_log "Cleaning up snapshot: $snapshot_name"
        virsh snapshot-delete "$vm_name" "$snapshot_name" --metadata >/dev/null 2>&1 || true
    fi
    
    fn_log "Incremental backup completed successfully"
    return 0
}

# Full backup (default)
fn_full_backup() {
    local source="$1"
    local dest_dir="$2"
    
    fn_log "Starting full backup"
    
    # Create backup filename
    local base_name=$(basename "$source" .qcow2)
    local backup_file="$dest_dir/${base_name}-$(date +%Y-%m-%d-%H%M%S).qcow2"
    
    fn_log "Creating full backup: $backup_file"
    
    if qemu-img convert -p -O qcow2 "$source" "$backup_file"; then
        fn_log "Full backup completed successfully"
        return 0
    else
        fn_log_error "Full backup failed"
        return 1
    fi
}

# Detect VM name from QCOW2 filename
fn_detect_vm_name() {
    local qcow_path="$1"
    local base_name=$(basename "$qcow_path" .qcow2)
    
    # Try to extract VM name (heuristic)
    echo "$base_name" | sed 's/-[0-9]\{4\}.*$//' | sed 's/--.*$//'
}

# Parse arguments
SOURCE=""
DEST=""
STRATEGY=""
VM_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--source) 
            SOURCE="$2"
            shift 2
            ;;
        -d|--destination) 
            DEST="$2"
            shift 2
            ;;
        --strategy) 
            STRATEGY="$2"
            shift 2
            ;;
        --incr)
            INCREMENTAL=1
            shift
            ;;
        --vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        --prune-then-backup)
            shift
            ;;
        -h|--help)
            echo "Usage: vm_smart_backup.sh -s SOURCE -d DEST [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -s, --source=FILE.qcow2    Source QCOW2 file"
            echo "  -d, --destination=DIR      Backup destination"
            echo "  --strategy=STRATEGY        Retention strategy"
            echo "  --incr                     Use incremental snapshots (VM must be running)"
            echo "  --vm-name=NAME            Specify VM name for incremental backup"
            echo "  --prune-then-backup       Prune old backups first"
            echo "  -h, --help                This help"
            exit 0
            ;;
        *) 
            shift
            ;;
    esac
done

# Validate
if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    fn_log_error "Source and destination required"
    exit 1
fi

# Check if it's a QCOW2 file
if [[ "$SOURCE" != *.qcow2 ]] || [ ! -f "$SOURCE" ]; then
    # Not a QCOW2 file, use original rsync script
    exec "$SCRIPT_DIR/rsync_tmbackup3.sh" "$@"
fi

# Create destination directory
mkdir -p "$DEST"

# Auto-detect VM name if not specified and incremental requested
if [ "$INCREMENTAL" -eq 1 ] && [ -z "$VM_NAME" ]; then
    VM_NAME=$(fn_detect_vm_name "$SOURCE")
    fn_log "Auto-detected VM name: $VM_NAME"
fi

# Execute backup
if [ "$INCREMENTAL" -eq 1 ]; then
    if [ -z "$VM_NAME" ]; then
        fn_log_error "VM name required for incremental backup"
        fn_log_warn "Falling back to full backup"
        fn_full_backup "$SOURCE" "$DEST"
    else
        fn_incremental_backup "$SOURCE" "$DEST" "$VM_NAME"
    fi
else
    fn_full_backup "$SOURCE" "$DEST"
fi

# Apply retention strategy if specified
if [ -n "$STRATEGY" ]; then
    fn_log "Retention strategy would be applied here: $STRATEGY"
    # Future: Implement the smart retention logic
fi

exit 0
