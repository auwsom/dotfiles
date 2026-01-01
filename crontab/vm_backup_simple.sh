#!/bin/bash
# Simple exact copy of working manual command

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_destination_directory>"
    exit 1
fi

BACKUP_DIR="$1"
VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
TIMESTAMP=$(date +%s)
BACKUP_FILE="${BACKUP_DIR}/simple-test-${TIMESTAMP}.qcow2"

echo "=== Simple Exact Manual Command Test ==="
echo "Running: sudo virsh blockcopy ${VM_NAME} vda ${BACKUP_FILE} --transient-job"

# Run exact same command that works manually
sudo virsh blockcopy "${VM_NAME}" vda "${BACKUP_FILE}" --transient-job

echo "Exit code: $?"
echo "Test complete"
