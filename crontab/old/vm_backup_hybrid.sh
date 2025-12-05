#!/bin/bash
# vm_backup_hybrid.sh - Hybrid backup with multiple fallback methods
set -o errexit
set -o nounset

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
DOMAIN_ID="22"  # From our testing
SOURCE="$1"
DEST_DIR="$2"
BACKUP_FILE="$DEST_DIR/$(basename "$SOURCE").$(date +%Y%m%d-%H%M%S).qcow2"

fn_log() { echo "[INFO] $(date) $1"; }
fn_log_warn() { echo "[WARN] $(date) $1"; }
fn_log_error() { echo "[ERROR] $(date) $1"; }

# Method 1: Direct blockcopy (manual-style)
fn_method_blockcopy() {
    fn_log "Method 1: Attempting direct blockcopy..."
    
    # Use same command that worked manually
    if timeout 30 virsh blockcopy "$VM_NAME" vda "$BACKUP_FILE" --transient-job; then
        if [[ -f "$BACKUP_FILE" ]]; then
            fn_log "✓ Blockcopy succeeded: $BACKUP_FILE"
            ls -lh "$BACKUP_FILE"
            return 0
        else
            fn_log_warn "Blockcopy succeeded but file not created"
        fi
    fi
    return 1
}

# Method 2: QEMU monitor (bypass libvirt)
fn_method_qemu_monitor() {
    fn_log "Method 2: Attempting QEMU monitor approach..."
    
    # First check current block jobs
    local jobs=$(timeout 10 virsh qemu-monitor-command "$DOMAIN_ID" '{"execute":"query-block-jobs"}' 2>&1)
    fn_log "Current block jobs: $jobs"
    
    # Try creating backup via monitor
    fn_log "QEMU monitor method limited - falling back to Method 3"
    return 1
}

# Method 3: External snapshot pattern (most reliable)
fn_method_snapshot() {
    fn_log "Method 3: External snapshot pattern..."
    
    local snapshot_name="backup-snapshot-$(date +%s)"
    local snapshot_file="$DEST_DIR/$snapshot_name.qcow2"
    
    # Step 1: Create external snapshot
    fn_log "Creating snapshot: $snapshot_name"
    if timeout 20 virsh snapshot-create-as "$VM_NAME" "$snapshot_name" --disk-only --atomic; then
        fn_log "✓ Snapshot created"
        
        # Step 2: Backup the now-frozen base file
        fn_log "Backing up frozen base file..."
        if cp "$SOURCE" "$BACKUP_FILE"; then
            fn_log "✓ Base backup created: $BACKUP_FILE"
            
            # Step 3: Merge changes back
            fn_log "Merging changes with blockcommit..."
            if timeout 30 virsh blockcommit "$VM_NAME" vda --active --wait; then
                fn_log "✓ Changes merged successfully"
                
                # Step 4: Cleanup snapshot
                virsh snapshot-delete "$VM_NAME" "$snapshot_name" --metadata 2>/dev/null || true
                rm -f "$snapshot_file" 2>/dev/null || true
                fn_log "✓ Cleanup completed"
                
                return 0
            fi
        fi
    fi
    
    fn_log_error "Snapshot method failed"
    return 1
}

# Method 4: Emergency qemu-img convert
fn_method_emergency() {
    fn_log "Method 4: Emergency qemu-img convert (requires VM stop)..."
    fn_log_warn "This will temporarily stop the VM!"
    
    # Stop VM
    virsh shutdown "$VM_NAME"
    sleep 10
    
    # Create backup
    if qemu-img convert -p -O qcow2 "$SOURCE" "$BACKUP_FILE"; then
        fn_log "✓ Emergency backup created"
        
        # Start VM
        virsh start "$VM_NAME"
        return 0
    else
        fn_log_error "Emergency backup failed"
        virsh start "$VM_NAME"
        return 1
    fi
}

# Main execution
fn_main() {
    if [[ -z "$SOURCE" || -z "$DEST_DIR" ]]; then
        fn_log_error "Usage: $0 <source> <dest_dir>"
        exit 1
    fi
    
    mkdir -p "$DEST_DIR"
    
    fn_log "=== Starting hybrid backup ==="
    fn_log "Source: $SOURCE"
    fn_log "Destination: $DEST_DIR"
    
    # Try methods in order of preference
    if fn_method_blockcopy; then
        fn_log "✓ Backup completed via Method 1 (Blockcopy)"
    elif fn_method_snapshot; then
        fn_log "✓ Backup completed via Method 3 (Snapshot)"
    elif fn_method_qemu_monitor; then
        fn_log "✓ Backup completed via Method 2 (QEMU Monitor)"
    elif fn_method_emergency; then
        fn_log "✓ Backup completed via Method 4 (Emergency)"
    else
        fn_log_error "All backup methods failed!"
        exit 1
    fi
    
    fn_log "=== Hybrid backup completed successfully ==="
}

fn_main "$@"
