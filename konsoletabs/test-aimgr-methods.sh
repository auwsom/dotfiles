#!/bin/bash
# Test different aimgr switch methods

echo "Method 1: Direct sudo to aimgr with cd"
timeout 3s sudo -u aimgr bash -c 'cd ~/dev/avoli && pwd && whoami'

echo ""
echo "Method 2: Using su"
timeout 3s su - aimgr -c 'cd ~/dev/avoli && pwd && whoami'

echo ""
echo "Method 3: Simple sudo with explicit path"
timeout 3s sudo -u aimgr bash -c 'cd /home/aimgr/dev/avoli && pwd && whoami'
