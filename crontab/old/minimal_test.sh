#!/bin/bash
echo "=== MINIMAL TEST ==="
echo "Command: sudo virsh blockcopy ubuntu20.04-kvm-img--mini--set2--kub--pers vda /media/user/backups3/rtb-ai-test/minimal-test-$(date +%s).qcow2 --transient-job"
echo "Executing now..."

sudo virsh blockcopy ubuntu20.04-kvm-img--mini--set2--kub--pers vda /media/user/backups3/rtb-ai-test/minimal-test-$(date +%s).qcow2 --transient-job

echo "Exit code: $?"
echo "Done."
