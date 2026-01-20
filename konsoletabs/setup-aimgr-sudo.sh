#!/bin/bash
# Setup passwordless sudo for aimgr user switching

# Add line to sudoers file (requires sudo access)
echo "user ALL=(ALL) NOPASSWD: /bin/su - aimgr" | sudo tee -a /etc/sudoers.d/aimgr-switch

echo "Passwordless sudo configured for switching to aimgr user"
