#!/bin/bash

# VM SSH script with correct key format
# Usage: ./vm_ssh.sh "command to execute"

SSH_KEY="$HOME/.ssh/vm_permanent_key"
VM_HOST="root@192.168.122.133"
SSH_PORT="443"

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"command to execute\""
    echo "Example: $0 \"ls -la\""
    exit 1
fi

COMMAND="$1"

echo "Executing on VM: $COMMAND"
ssh -i "$SSH_KEY" -p "$SSH_PORT" "$VM_HOST" "su - user -c '$COMMAND'"
