Services Disabled:
- docker.socket (auto-start)
- docker.service (boot)
- OpenProject containers
- avoli-orchestrator.service
- avoli-persistent-queue.service

# Goose Process Priority Fix
# Applied: Mon Nov 17 21:18:30 PST 2025
# Purpose: Give Goose processes higher priority than test processes
# Prevents Goose from becoming unresponsive during test execution

## Configuration:
- Nice value: -10 (high priority)
- Test processes: 19 (low priority)
- Result: Goose gets CPU/I/O resources first

## Files Created:
- /etc/systemd/system/goose-priority.service
- /etc/systemd/system/goose-priority.service.d/priority.conf

## Service Status:
- Enabled: Yes
- Active: Will start on boot

## Manual Activation:
systemctl start goose-priority.service


# December 2025 - Enhanced VM-Compatible Controls

## Core Isolation (Primary Protection)
⚠️  **VM-SPECIFIC NOTE**: Standard systemd slice CPU allocation is unreliable in VM environments. Explicit core affinity is used instead.

- Desktop/User (user-1000): Cores 0-1 (reserved and protected)
- AIMGR (user-1003): Cores 2-19 (testing workloads)
- Command: `systemctl set-property user-*.slice AllowedCPUs=*-*`

## Memory and Process Limits
⚠️  **VM-SPECIFIC NOTE**: Slice-based limits work but require explicit verification.

- AIMGR Memory Limit: 4GB enforced via systemd slice
- AIMGR Process Limit: 200 maximum via TasksMax
- Desktop Memory Protection: 1GB reserved via MemoryLow

## Priority Management
⚠️  **VM-SPECIFIC NOTE**: CPUShares differential is one of the few reliable priority controls in VMs.

- Desktop Priority: CPUShares=1024 (high priority)
- AIMGR Priority: CPUShares=256 (lower priority)
- Result: Desktop processes get resources first even under load

## Enhanced Protection Tools (December 2025)

### Optimized Test Runner
Path: `/home/user/bin/optimized_test_runner.sh`
- Fast test execution with built-in safety monitoring
- Automatic timeout (20s) and load threshold (5.0)
- Core isolation verification during test execution

### Targeted Process Killer
Path: `/home/user/bin/kill_aimgr_processes.sh`
- Selective termination of test-related processes only
- Preserves shell sessions, services, and non-test workloads
- Safe emergency stop without disrupting other AIMGR activities

### Long Test Runner
Path: `/home/user/bin/long_test_runner.sh`  
- Extended timeout (45s) for comprehensive test suites
- Lower monitoring thresholds for intensive testing
- Progress reporting during long executions

## VM Environment Limitations Documented
- Standard cgroup v2 enforcement inconsistent in VMs
- Slice-based resource controls require explicit configuration
- Core affinity restrictions are the most reliable isolation method
- TasksMax and CPUShares provide essential backup protection

## Verification Commands:
```bash
# Check core allocation
systemctl show user-1000.slice | grep AllowedCPUs
systemctl show user-1003.slice | grep AllowedCPUs

# Check resource limits
systemctl show user-1003.slice | grep -E "MemoryMax|TasksMax|CPUShares"

# Monitor process distribution
ps -u aimgr -o psr= | sort -n | uniq -c
ps -u user -o psr= | sort -n | uniq -c
```
