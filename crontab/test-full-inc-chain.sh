#!/bin/bash
# Test full + incremental backup workflow

VM_NAME="ubuntu20.04-kvm-img--mini--set2--kub--pers"
BASE_DIR="/media/user/temp/restore-test-$(date +%Y%m%d-%H%M%S)"

echo "=== TESTING FULL + INCREMENTAL BACKUP WORKFLOW ==="
echo "Base directory: $BASE_DIR"
mkdir -p "$BASE_DIR"

# Step 1: Create full backup (base for incremental)
echo "=== STEP 1: CREATING FULL BACKUP ==="
FULL_DIR="$BASE_DIR/full-base"
sudo virtnbdbackup -d "$VM_NAME" -l full -t stream -o "$FULL_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Full backup created successfully"
    echo "Full backup location: $FULL_DIR"
    
    # Step 2: Create incremental backup 
    echo "=== STEP 2: CREATING INCREMENTAL BACKUP (after full) ==="
    INC_DIR="$BASE_DIR/incremental"
    sudo virtnbdbackup -d "$VM_NAME" -l inc -t stream -o "$INC_DIR"
    
    if [ $? -eq 0 ]; then
        echo "✅ Incremental backup created successfully"
        echo "Incremental backup location: $INC_DIR"
        
        # Check what was created
        echo "=== BACKUP FILES CREATED ==="
        find "$BASE_DIR" -name "*.data" -o -name "*.qcow.json" | head -10
        
        # Step 3: Test restoring/merging (simulated)
        echo "=== STEP 3: TESTING RESTORE CAPABILITY ==="
        echo "Incremental backup chain should be ready for restore/merge"
        echo "Use: virtnbdrestore -i '$BASE_DIR' to restore"
        
        echo "✅ TEST COMPLETE - Backup chain ready for restore testing"
    else
        echo "❌ Incremental backup failed"
    fi
else
    echo "❌ Full backup failed"
fi
