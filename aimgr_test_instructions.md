# HOW TO RUN TEST FROM AIMGR USER (SU'ED FROM USER DESKTOP)

## Step 1: Normal su to aimgr
```bash
su aimgr
```

## Step 2: Move your shell to correct AIMGR cgroup
```bash
# Get your shell PID
echo $$

# Move your shell to AIMGR cgroup (cores 4-19)
echo $$ > /sys/fs/cgroup/user.slice/user-1003.slice/cgroup.procs
```

## Step 3: Navigate to project and activate environment
```bash
cd /home/aimgr/dev/avoli/agent2
source /home/aimgr/venv2/bin/activate
```

## Step 4: Run your test (will now use cores 4-19)
```bash
python3 chat.py --test
```

## OR: One-liner command from user desktop
```bash
# Run test directly as aimgr with proper cgroup
sudo -u aimgr bash -c 'echo $$ > /sys/fs/cgroup/user.slice/user-1003.slice/cgroup.procs && cd /home/aimgr/dev/avoli/agent2 && source /home/aimgr/venv2/bin/activate && python3 chat.py --test'
```

## Verification Steps
After moving to the correct cgroup, you can verify:
```bash
# Check your cgroup
cat /proc/self/cgroup

# Check your core affinity
taskset -p $$
```

This should show:
- Cgroup: `/user.slice/user-1003.slice`
- Affinity: Should allow cores 4-19

## Why This Works
- System/Desktop: Protected cores 0-1
- User Applications: Cores 2-3  
- AIMGR Processes: Cores 4-19 (after manual cgroup move)
