#!/bin/bash
echo "=== Simple Test ==="
echo "Running: virsh list --all"
virsh list --all
echo "Exit code: $?"
echo "---"
echo "Running: virsh dominfo ubuntu20.04-kvm-img--mini--set2--kub--pers"
virsh dominfo ubuntu20.04-kvm-img--mini--set2--kub--pers
echo "Exit code: $?"
echo "Test complete"
