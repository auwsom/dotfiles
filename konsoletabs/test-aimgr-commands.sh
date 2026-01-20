#!/bin/bash
# Test different commands for aimgr user switching

echo "Testing different aimgr startup commands..."

# Option 1: Current approach
echo "Option 1: sudo -u aimgr bash"
konsole --profile "aimgr" &

sleep 2

# Option 2: Using su directly  
echo "Option 2: su - aimgr"
# Update profile to use: Command=/bin/bash -c "su - aimgr\n"

# Option 3: Using login
echo "Option 3: sudo -i -u aimgr"
# Update profile to use: Command=/bin/bash -c "sudo -i -u aimgr\n"

echo "Test which option works best for your setup"
