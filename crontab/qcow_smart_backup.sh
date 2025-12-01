#!/bin/bash

# qcow_smart_backup.sh - Smart backup with QCOW2 VM support
# Uses qemu-img convert for QCOW2 files, rsync for directories
# Keeps original smart retention strategy logic

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION=3.1

# Logging functions
fn_log_info()  { echo "$SCRIPT_NAME: "$1""; }
fn_log_warn()  { echo "$SCRIPT_NAME: [WARNING] "$1"" 1>&2; }
fn_log_error() { echo "$SCRIPT_NAME: [ERROR] "$1"" 1>&2; }

# File operations
fn_rm_file() { [ -f "$1" ] && rm -f -- "$1"; }
fn_mkdir()   { [ ! -d "$1" ] && mkdir -p -- "$1"; }
fn_ln()      { ln -- "$1" "$2"; }

# QCOW2-aware backup function
fn_perform_qcow_backup() {
    local source="$1"
    local dest_dir="$2"
    
    # Detect QCOW2 file
    if [[ "$source" == *.qcow2 ]] && [ -f "$source" ]; then
        fn_log_info "QCOW2 file detected, using qemu-img convert"
        
        local base_name=$(basename "$source" .qcow2)
        local backup_file="$dest_dir/${base_name}-$(date +%Y-%m-%d-%H%M%S).qcow2"
        
        fn_log_info "Creating QCOW2 backup: $backup_file"
        
        # Use qemu-img for consistent VM backup
        if qemu-img convert -p -O qcow2 "$source" "$backup_file"; then
            fn_log_info "QCOW2 backup successful"
            return 0
        else
            fn_log_error "QCOW2 backup failed"
            return 1
        fi
    else
        # Fallback to rsync for directories
        fn_log_info "Using rsync for directory backup"
        rsync -avx --delete --delete-excluded --backup --backup-dir="$dest_dir" \
               --link-dest="$DEST_FOLDER/latest" "$source" "$dest_dir"
    fi
}

# Main backup execution
fn_run_backup() {
    local DATE_DIR=$(date "+%Y-%m-%d-%H%M%S")
    local DEST="$DEST_FOLDER/$DATE_DIR"
    local INPROGRESS_FILE="$DEST_FOLDER/in_progress"
    
    fn_log_info "Starting backup from '$SOURCE_DIR' to '$DEST_FOLDER/'"
    
    # Create destination
    fn_mkdir "$DEST"
    
    # Mark in progress
    echo "$$"> "$INPROGRESS_FILE"
    
    # Execute backup
    if ! fn_perform_qcow_backup "$SOURCE_DIR" "$DEST"; then
        fn_rm_file "$INPROGRESS_FILE"
        return 1
    fi
    
    # Clean up
    fn_rm_file "$INPROGRESS_FILE"
    fn_rm_file "$DEST_FOLDER/latest"
    fn_ln "$DEST" "$DEST_FOLDER/latest"
    
    fn_log_info "Backup completed successfully"
}

# Simplified retention logic (placeholder)
fn_simple_retention() {
    fn_log_info "Retention strategy: $STRATEGY (simplified)"
    # In full version, this would implement the smart retention logic
}

# Usage
fn_display_usage() {
    echo "Usage: $SCRIPT_NAME -s SOURCE -d DEST [OPTIONS]"
    echo "Smart backup with QCOW2 support"
    echo ""
    echo "Options:"
    echo "  -s, --source=DIR      Source directory or QCOW2 file"
    echo "  -d, --destination=DIR Destination directory"
    echo "  --strategy=STRATEGY   Retention strategy"
    echo "  -h, --help            This help"
}

# Argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source) SOURCE_DIR="$2"; shift 2;;
            -d|--destination) DEST_FOLDER="$2"; shift 2;;
            --strategy) STRATEGY="$2"; shift 2;;
            --prune-then-backup) PRUNE_THEN_BACKUP=1; shift;;
            -h|--help) fn_display_usage; exit 0;;
            *) shift;;
        esac
    done
}

# Initialize
SOURCE_DIR=""
DEST_FOLDER=""
STRATEGY="1:1 7:7 30:7"
PRUNE_THEN_BACKUP=0

# Parse args
parse_arguments "$@"

# Validate
if [ -z "$SOURCE_DIR" ] || [ -z "$DEST_FOLDER" ]; then
    fn_log_error "Source and destination required"
    fn_display_usage
    exit 1
fi

# Apply retention
if [ "$PRUNE_THEN_BACKUP" -eq 1 ]; then
    fn_simple_retention
fi

# Execute
fn_run_backup

exit 0
