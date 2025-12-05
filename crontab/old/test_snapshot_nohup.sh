#!/bin/bash
# Test snapshot in background with nohup

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
LOGFILE="/tmp/snapshot-test-$(date +%s).log"

echo "Testing snapshot creation in background..."
echo "Logging to: $LOGFILE"

nohup sudo virsh snapshot-create-as "$VM_NAME" test-snapshot-bg --disk-only --atomic > "$LOGFILE" 2>&1 &

PID=$!
echo "Started background process: PID $PID"
echo "Check log: tail -f $LOGFILE"
echo "Clean up: sudo virsh snapshot-delete $VM_NAME test-snapshot-bg --metadata"

# Wait a bit and check exit status
sleep 10
if kill -0 $PID 2>/dev/null; then
    echo "Process still running"
else
    echo "Process finished - check log"
fi
