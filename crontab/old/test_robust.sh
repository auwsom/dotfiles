#!/bin/bash
echo "=== Robust Test Script ==="

# Test 1: Short timeout on basic command
echo "1. Testing virsh list with 5s timeout..."
if timeout 5 virsh list --all; then
    echo "✓ virsh list succeeded"
else
    echo "✗ virsh list timed out (exit: $?)"
fi

# Test 2: Try with sudo and timeout
echo "2. Testing sudo virsh list with 5s timeout..."
if timeout 5 sudo virsh list --all; then
    echo "✓ sudo virsh list succeeded"
else
    echo "✗ sudo virsh list timed out (exit: $?)"
fi

# Test 3: Direct domain lookup with timeout
echo "3. Testing domain lookup..."
if timeout 10 virsh dominfo ubuntu20.04-kvm-img--mini--set2--kub--pers; then
    echo "✓ Domain found"
else
    echo "✗ Domain not found or timed out (exit: $?)"
fi

echo "=== Test complete ==="
