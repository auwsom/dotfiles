#!/bin/bash
# vm_smart_backup_test.sh - Test version with timeout
set -o errexit
set -o nounset
set -o pipefail

echo "=== Starting backup test ==="
echo "Source: $1"
echo "Dest: $2"

source="$1"
dest_dir="$2"

# Extract VM name from backup path
vm_name=""
if [[ "$dest_dir" == *"rtb-ai"* ]]; then
    vm_name="ubuntu20.04-kvm-img--mini--set2--kub--pers"
    echo "Detected AI VM: $vm_name"
elif [[ "$dest_dir" == *"rtb-pers"* ]]; then
    vm_name="ubuntu20.04-kvm-img--mini--set2--kub--pers"
    echo "Detected Pers VM: $vm_name"
else
    vm_name="$(basename "$source" .qcow2)"
    echo "Auto-detected VM: $vm_name"
fi

# Create destination directory
mkdir -p "$dest_dir"

# Generate backup filename
timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="$dest_dir/$(basename "$source").$timestamp.qcow2"

echo "Creating backup: $backup_file"

# Test virsh connectivity first
echo "Testing virsh connectivity..."
virsh list --all | grep "$vm_name" && echo "VM found" || echo "VM not found"

# Try blockcopy with 30 second timeout
echo "Attempting blockcopy (30s timeout)..."
if timeout 30 virsh blockcopy "$vm_name" vda "$backup_file" --transient-job; then
    echo "SUCCESS: Blockcopy completed"
    ls -lh "$backup_file"
else
    echo "FAILED: Blockcopy timed out or failed"
    echo "Exit code: $?"
fi
