#!/bin/bash
# vm_smart_backup_simple.sh - Simple VM backup using virsh commands
set -o errexit
set -o nounset
set -o pipefail

fn_log() { echo "vm_smart_backup: [INFO] $(date) $1"; }
fn_log_error() { echo "vm_smart_backup: [ERROR] $(date) $1" 1>&2; }

fn_backup_qcow2() {
    local source="$1"
    local dest_dir="$2"
    
    fn_log "Starting QCOW2 backup: $source"
    
    # Create destination directory if needed
    mkdir -p "$dest_dir"
    
    # Generate backup filename with timestamp
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="$dest_dir/$(basename "$source").$timestamp.qcow2"
    
    fn_log "Creating backup: $backup_file"
    
    # Extract VM name from backup path
    local vm_name=""
    if [[ "$dest_dir" == *"rtb-ai"* ]]; then
        vm_name="ubuntu20.04-kvm-img--mini--set2--kub--pers"
    elif [[ "$dest_dir" == *"rtb-pers"* ]]; then
        vm_name="ubuntu20.04-kvm-img--mini--set2--kub--pers"  # Adjust as needed
    else
        vm_name="$(basename "$source" .qcow2)"
    fi
    
    fn_log "VM detected: $vm_name"
    
    # Simple blockcopy
    fn_log "Executing: virsh blockcopy $vm_name vda $backup_file --transient-job"
    virsh blockcopy "$vm_name" vda "$backup_file" --transient-job
    
    if [[ $? -eq 0 ]]; then
        fn_log "Blockcopy succeeded: $backup_file"
        echo "$backup_file"
        return 0
    else
        fn_log_error "Blockcopy failed"
        return 1
    fi
}

# Parse arguments
source=""
dest_dir=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source) source="$2"; shift 2 ;;
        -d|--dest) dest_dir="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [[ -z "$source" || -z "$dest_dir" ]]; then
    fn_log_error "Usage: $0 -s SOURCE -d DEST"
    exit 1
fi

fn_backup_qcow2 "$source" "$dest_dir"
