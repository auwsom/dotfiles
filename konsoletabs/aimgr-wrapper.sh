#!/bin/bash
# Wrapper script to switch to aimgr user and cd to ~/dev/avoli

exec sudo -u aimgr bash -c "cd ~/dev/avoli && exec bash"
