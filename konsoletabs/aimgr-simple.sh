#!/bin/bash
cd /home/aimgr/dev/avoli
# Activate venv2 and make sv2 alias persistent
source /home/user/venv2/bin/activate
echo 'alias sv2="source /home/user/venv2/bin/activate"' >> ~/.bashrc
exec sudo -u aimgr bash
