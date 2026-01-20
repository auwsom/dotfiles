#!/bin/bash
# Test different methods to switch to aimgr user

echo "Testing aimgr user switching methods..."

# Method 1: Direct sudo (may prompt for password)
echo "=== Method 1: sudo -u aimgr bash ==="
timeout 5s sudo -u aimgr whoami

echo ""

# Method 2: Using su (may prompt for password)
echo "=== Method 2: su - aimgr ==="
timeout 5s su - aimgr -c whoami

echo ""

# Method 3: Check if user can switch without password
echo "=== Method 3: Check sudoers ==="
sudo -l -U user 2>/dev/null | grep aimgr || echo "No specific sudo rules for aimgr"

echo ""

# Method 4: Test current user switching to aimgr
echo "=== Method 4: Manual test ==="
echo "Current user: $(whoami)"
echo "Trying to switch to aimgr..."

# Try the command that's in the profile
echo "Testing: sudo -u aimgr bash"
if timeout 3s sudo -u aimgr bash -c "whoami" 2>/dev/null; then
    echo "SUCCESS: sudo -u aimgr works without password"
else
    echo "FAILED: sudo -u aimgr requires password or failed"
fi

echo "Testing: su - aimgr"
if timeout 3s su - aimgr -c "whoami" 2>/dev/null; then
    echo "SUCCESS: su - aimgr works"
else
    echo "FAILED: su - aimgr requires password or failed"
fi
