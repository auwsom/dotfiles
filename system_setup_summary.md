# System Setup Summary

## Display Configuration
- Resolution: 3840x2050 @ 60Hz
- Scaling: Normal (1x1)
- Autostart: ~/.config/autostart/set-resolution.desktop
- Fix: Added Plasma reload command after resolution change

## Resource Allocation
- Total Cores: 20
- System: 0-1 (2 cores - reserved for desktop/system)
- AIMGR: 2-19 (18 cores - testing workloads)
- Memory: 4GB limit for AIMGR enforced

## System Protection
- Desktop OOM: -1000 score
- Emergency kill: /home/user/bin/kill_aimgr_processes.sh
- Safe testing: 20-25 second timeouts with monitoring
- CPU Priority: Desktop (1024) > AIMGR (256) CPUShares

## VM Environment Considerations
⚠️  **VM-SPECIFIC LIMITATIONS:**
- Standard cgroup v2 and systemd slice methods have reliability issues in VM environments
- CPU core affinity restrictions are the most reliable isolation mechanism
- Memory and process limits work but require explicit configuration
- TasksMax and CPUShares provide essential backup protection when slices don't work properly

## Status
- ✅ Display scaling fixed
- ✅ System stable under load
- ✅ Desktop responsive during tests
- ✅ Core allocation COMPLETE and working
- ✅ VM-compatible protection systems active

## Enhanced Protection Controls (December 2025)
- TasksMax=200 for AIMGR process containment
- CPUShares differential (1024 vs 256) for priority management
- Targeted kill scripts: /home/user/bin/kill_aimgr_processes.sh
- Optimized test runners with automatic monitoring
