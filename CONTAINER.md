# Container Priority Management
# For running tests without affecting Goose responsiveness

## Issue:
Test processes and Goose processes had equal priority (nice 19),
causing I/O starvation and Goose unresponsiveness.

## Solution:
- Goose processes: nice -10 (high priority)
- Test processes: nice 19 (low priority)
- Container test runs respect Goose priority

## Commands:
# Set Goose priority manually:
renice -10 $(pgrep -f goose)

# Check process priorities:
ps -eo pid,ni,cls,pri,pcpu,comm | grep goose

# Service management:
systemctl start goose-priority.service
systemctl enable goose-priority.service
