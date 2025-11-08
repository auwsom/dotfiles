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
=== FINAL STATUS ===
Test process terminated

Core usage check:
cpu3 35545 315122 169872 1322854 69322 0 2009 151 0 0
cpu4 2109 45220 54870 1777929 47420 0 125 61 0 0
cpu5 1077 45898 55897 1734330 89667 0 25 58 0 0
cpu6 719 46797 51753 1781263 48127 0 23 48 0 0

Plan status: Cgroup move failed, but test started and terminated normally. Core assignment still not working.
