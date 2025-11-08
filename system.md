# SYSTEM FIX PLAN - FOOLPROOF

## PROBLEM
Cores 2-3 overloaded with 313,000+ processes
Cores 4-19 idle (should be AIMGR)
AIMGR processes using wrong cores

## ROOT CAUSE
AIMGR session PID 352533 in konsole cgroup
Need to move to user-1003.slice with cores 4-19

## SIMPLE PLAN
1. Kill everything AIMGR: pkill -9 -u aimgr
2. Create AIMGR cgroup with cores 4-19
3. Start AIMGR session directly in correct cgroup
4. Test core allocation
