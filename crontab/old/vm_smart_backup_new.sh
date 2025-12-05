#!/bin/bash
# vm_smart_backup_new.sh - VM backup with timeout wrappers and QEMU monitor fallback
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_PATH="$(readlink -f \"\$0\")"
SCRIPT_DIR="$(dirname \"\$SCRIPT_PATH\")"

# Configuration
TIMEOUT=30
VM_NAME=""
DOMAIN_ID="22"  # Our VM's domain ID

# Logging
fn_log() { echo "vm_smart_backup: [INFO] \$(date) \$1"; }
fn_log_warn() { echo "vm_smart_backup: [WARNING] \$(date) \$1" 1>&2; }
fn_log_error() { echo "vm_smart_backup: [ERROR] \$(date) \$1" 1>&2; }

# Safe virsh command with timeout
fn_virsh() {
    local cmd="\$1"
    local timeout=\${2:-\$TIMEOUT}
    timeout "\$timeout" virsh "\$cmd" 2>&1
}

# QEMU monitor fallback
fn_qemu_monitor() {
    local cmd="\$1"
    local timeout=\${2:-15}
    timeout "\$timeout" virsh qemu-monitor-command "\$DOMAIN_ID" "\$cmd" 2>&1
}

# Check if file is QCOW2
fn_is_qcow2() {
    local file="\$1"
    [[ -f "\$file" ]] && file "\$file" | grep -q "QEMU QCOW"
}

# QCOW2 backup using blockcopy with error handling
fn_backup_qcow2() {
    local source="\$1"
    local dest_dir="\$2"
    local vm_name="\$3"
    
    fn_log "Starting QCOW2 backup for VM: \$vm_name"
    
    # Create destination directory if needed
    mkdir -p "\$dest_dir"
    
    # Generate backup filename with timestamp
    local timestamp=\$(date +%Y%m%d-%H%M%S)
    local backup_file="\$dest_dir/\$(basename \"\$source\").\$timestamp.qcow2"
    
    fn_log "Creating backup: \$backup_file"
    
    # Method 1: Try blockcopy with timeout
    fn_log "Attempting blockcopy backup..."
    local result=\$(fn_virsh "blockcopy \$vm_name vda \$backup_file --transient-job" 60)
    
    if [[ \$? -eq 0 ]]; then
        fn_log "Blockcopy succeeded"
        echo "\$backup_file"
        return 0
    fi
    
    # Method 2: Fallback to qemu-img convert with VM shutdown
    fn_log "Blockcopy failed, trying qemu-img convert..."
    fn_log_warn "This requires stopping the VM temporarily"
    
    fn_virsh "shutdown \$vm_name"
    sleep 10
    
    if qemu-img convert -p -O qcow2 "\$source" "\$backup_file"; then
        fn_log "QCOW2 conversion succeeded"
        fn_virsh "start \$vm_name"
        echo "\$backup_file"
        return 0
    else
        fn_log_error "All backup methods failed"
        fn_virsh "start \$vm_name"
        return 1
    fi
}

# Directory backup using rsync (fallback)
fn_backup_directory() {
    local source="\$1"
    local dest_dir="\$2"
    
    fn_log "Starting directory backup: \$source"
    
    # Use the original rsync_tmbackup3.sh
    if [[ -f "\$SCRIPT_DIR/rsync_tmbackup3.sh" ]]; then
        "\$SCRIPT_DIR/rsync_tmbackup3.sh" "\$@"
    else
        fn_log_error "rsync_tmbackup3.sh not found"
        return 1
    fi
}

# Main backup function
fn_main() {
    local source=""
    local dest_dir=""
    local args=()
    
    while [[ \$# -gt 0 ]]; do
        case \$1 in
            -s|--source) source="\$2"; shift 2 ;;
            -d|--dest) dest_dir="\$2"; shift 2 ;;
            *) args+=(\"\$1\"); shift ;;
        esac
    done
    
    if [[ -z "\$source" || -z "\$dest_dir" ]]; then
        fn_log_error "Source (-s) and destination (-d) required"
        exit 1
    fi
    
    # Auto-detect VM name from filename if not provided
    if [[ -z "\$VM_NAME" ]]; then
        VM_NAME="\$(basename "\$source" .qcow2)"
    fi
    
    # Choose backup method based on file type
    if fn_is_qcow2 "\$source"; then
        fn_backup_qcow2 "\$source" "\$dest_dir" "\$VM_NAME"
    else
        fn_backup_directory "\$source" "\$dest_dir" "\${args[@]}"
    fi
}

# Handle script arguments
case "\${1:-}" in
    --help|-h)
        echo "Usage: \$0 -s SOURCE -d DEST [OPTIONS]"
        echo "Options:"
        echo "  -s, --source    Source file/directory"
        echo "  -d, --dest      Destination directory"
        echo "  --vm-name NAME  Specify VM name (default: auto-detected)"
        exit 0
        ;;
    *)
        fn_main "\$@"
        ;;
esac

