#!/bin/bash
echo "=== Manual SSH Setup for 192.168.122.220 ==="

# 1. Copy SSH key (will prompt for password)
echo "Step 1: Copying SSH key (enter password when prompted)"
ssh-copy-id user@192.168.122.220

# 2. Test connection
echo "Step 2: Testing connection"
if ssh -o BatchMode=yes user@192.168.122.220 "echo SSH connection successful"; then
    echo "✅ SSH key authentication working!"
else
    echo "❌ SSH key authentication failed"
fi

# 3. Set up config for easier access
echo "Step 3: Setting up SSH config"
echo "
Host vm220
    HostName 192.168.122.220
    User user
    IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config

chmod 600 ~/.ssh/config
echo "✅ SSH config updated - use 'ssh vm220' for easier access"

echo "=== Setup complete ==="
