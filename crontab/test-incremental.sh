#!/bin/bash
# Test incremental backup and merge verification

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
TEST_DIR="/media/user/temp/incremental-test-$(date +%Y%m%d-%H%M%S)"

echo "=== TESTING INCREMENTAL BACKUP WORKFLOW ==="
echo "Test directory: $TEST_DIR"
mkdir -p "$TEST_DIR"

# Check if VM is running properly first
echo "=== CHECKING VM STATUS ==="
sudo timeout 5 virsh list --all | grep "$VM_NAME" || echo "VM not found or libvirt issue"

# Try WITHOUT suspend first to see if incremental backup works
echo "=== ATTEMPTING INCREMENTAL BACKUP WITHOUT SUSPEND ==="
sudo virtnbdbackup -d "$VM_NAME" -l inc -t stream -o "$TEST_DIR"
BACKUP_EXIT=$?

if [ $BACKUP_EXIT -eq 0 ]; then
    echo "✅ Incremental backup completed successfully"
    echo "Backup location: $TEST_DIR"
    find "$TEST_DIR" -type f | head -10
    
    # Test if we can mount to verify contents (stream format)
    echo "=== VERIFYING BACKUP CONTENTS ==="
    sudo mkdir -p /tmp/test-mount
    
    # Try different mounting approaches
    for FILE in "$TEST_DIR"/*.data; do
        if [ -f "$FILE" ]; then
            echo "Found backup file: $FILE"
            
            # Convert to qcow2 for easier mounting
            QCOW_FILE="$TEST_DIR/backup.qcow2"
            echo "Converting to qcow2 for testing..."
            qemu-img convert -f raw -O qcow2 "$FILE" "$QCOW_FILE"
            
            # Mount the qcow2 file
            echo "Mounting for verification..."
            sudo qemu-nbd --connect /dev/nbd10 "$QCOW_FILE"
            sleep 2
            sudo mount /dev/nbd10p1 /tmp/test-mount 2>&1
            
            if mountpoint /tmp/test-mount >/dev/null 2>&1; then
                echo "✅ Successfully mounted!"
                echo "Test files found:"
                find /tmp/test-mount/home/user -name "test-*" 2>/dev/null | head -5
                
                # Cleanup
                sudo umount /tmp/test-mount
                sudo qemu-nbd --disconnect /dev/nbd10
                break
            else
                echo "❌ Could not mount backup"
                sudo qemu-nbd --disconnect /dev/nbd10 2>/dev/null
            fi
        fi
    done
    
    echo "=== INCREMENTAL BACKUP TEST COMPLETE ==="
    echo "Script completed - check if backup contains recent test files"
else
    echo "❌ Incremental backup failed with exit code: $BACKUP_EXIT"
    echo "Backup may require a full backup as base first"
fi
