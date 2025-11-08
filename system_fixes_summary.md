# System Fixes Summary

## CPU Core Allocation & Cgroup Setup

### 1. Core Separation Configuration
- **System/Desktop Cores**: 0-1 (protected for UI responsiveness)
- **Application Cores**: 2-19 (dedicated for intensive workloads)

### 2. Cgroup Configuration

#### User Slice Setup:
```bash
# AIMGR user (worker processes)
- User: aimgr (UID 1001)
- Slice: user-1001.slice
- CPU Quota: 90% (900ms per second)
- Cores: 2-19
- Cgroup path: /sys/fs/cgroup/user.slice/user-1001.slice/

# ADMIN user (desktop/flutter)
- User: user (UID 1000) 
- Slice: user-1000.slice
- CPU Quota: 95% (increased from 80%)
- Cores: 0-19 (changed from 0-1 - THIS CAUSED PROBLEMS)
- Cgroup path: /sys/fs/cgroup/user.slice/user-1000.slice/
```

### 3. CPU Affinity Enforcement
```bash
# Set cpuset for AIMGR processes
echo '2-19' > /sys/fs/cgroup/user.slice/user-1001.slice/cpuset.cpus
echo '0' > /sys/fs/cgroup/user.slice/user-1001.slice/cpuset.mems

# Set cpuset for USER processes (BROKEN - should be 2-19, not 0-19)
echo '0-19' > /sys/fs/cgroup/user.slice/user-1000.slice/cpuset.cpus
echo '0' > /sys/fs/cgroup/user.slice/user-1000.slice/cpuset.mems

# Move processes to correct cgroups
ps aux | grep '^aimgr' | awk '{print $2}' | xargs -I {} echo {} > /sys/fs/cgroup/user.slice/user-1001.slice/cgroup.procs
```

### 4. Child PID Containment Issue
**PROBLEM**: When using `su - aimgr`, child processes (bash, python, etc.) don't inherit the cgroup properly.

**CURRENT STATUS**: Not fully fixed - child processes can escape to parent cgroup.

### 5. Zombie Process Management
```bash
# Aggressive zombie cleanup
pkill -9 -u aimgr
ps aux | grep defunct | awk '{print $2}' | xargs -r kill -9
```

## Desktop Performance Optimizations

### 6. Desktop Rendering Fix
**DISABLED**: Desktop compositing/effects that were causing UI lag:
```bash
# KDE Plasma desktop effects disabled
# This reduced CPU usage on cores 0-1 significantly
```

## Current Issues

### 7. CRITICAL PROBLEMS
1. **USER cgroup cores 0-19**: This broke core isolation - Flutter can now compete with desktop
2. **Child process containment**: Not working properly - processes escape cgroups
3. **Memory/I/O pressure**: No limits set - can saturate system resources
4. **System unresponsive**: Due to resource exhaustion

## Required Fixes

### 8. IMMEDIATE ACTIONS NEEDED
```bash
# 1. Fix USER cgroup - move off desktop cores
echo '2-19' > /sys/fs/cgroup/user.slice/user-1000.slice/cpuset.cpus

# 2. Protect desktop cores
echo '0-1' > /sys/fs/cgroup/user.slice/user-desktop.slice/cpuset.cpus

# 3. Set memory limits
echo '8G' > /sys/fs/cgroup/user.slice/user-1000.slice/memory.max

# 4. Enable cgroup subtree control for child processes
echo '+cpu' > /sys/fs/cgroup/user.slice/user-1001.slice/cgroup.subtree_control
echo '+memory' > /sys/fs/cgroup/user.slice/user-1001.slice/cgroup.subtree_control
```

## System Status
- **CPU allocation**: Partially working
- **Cgroup enforcement**: Broken for user (0-19 instead of 2-19)
- **Child containment**: Not working
- **Desktop protection**: Compromised
- **System**: UNRESPONSIVE due to resource exhaustion
