#!/bin/bash

# usb volumes
# /root/rsync-time-backup/rsync_tmbackup.sh  /media/user/16GBa /media/user/backups/rtb-usb
/home/user/git/dotfiles/crontab/rsync_tmbackup4.sh  -s /media/user/16GBa -d /media/user/backups/rtb-usb/ || echo "USB backup failed, continuing..."

# home dir minus .cache
# /root/rsync-time-backup/rsync_tmbackup.sh --rsync-append-flags "--exclude .cache"  /home/user /media/user/backups/rtb-home-user/
# /home/user/git/dotfiles/crontab/rsync_tmbackup3.sh  -s /home/user -d /media/user/backups/rtb-home-user/ --rsync-append-flags "--exclude .cache"
# /home/user/git/dotfiles/crontab/rsync_tmbackup3.sh  -s /home/user -d /media/user/backups/rtb-home-user/ --ex ".cache"
/home/user/git/dotfiles/crontab/rsync_tmbackup3.sh  -s /home/user -d /media/user/backups/rtb-home-user/ --rsync-append-flags "--exclude .cache" || echo "Home backup failed, continuing..."

# VMs minus work vm
# /root/rsync-time-backup/rsync_tmbackup.sh --rsync-append-flags "--exclude 100G-w" --strategy "1:1 7:1 30:7 365:30" /media/user/VM/ /media/user/backups/rtb-pers/
/home/user/git/dotfiles/crontab/rsync_tmbackup4.sh --prune-then-backup -s /media/user/VM/25G-p -d /media/user/backups/rtb-pers/ || echo "25G-p backup failed, continuing..."

# /home/user/git/dotfiles/crontab/rsync_tmbackup3.sh --prune-then-backup -s /media/user/VM/100G-w -d /media/user/temp/rtb-work/ --strategy "3:1 4:7 30:7" || echo "100G-w backup failed, continuing..."
/home/user/git/dotfiles/crontab/rsync_tmbackup3.sh --prune-then-backup -s /media/user/VM/100G-w -d /media/user/backups2/rtb-work/ --strategy "3:1 4:7 30:7" || echo "100G-w backup failed, continuing..."

# # AI VM with virtnbdbackup incremental chain
/home/user/git/dotfiles/crontab/virtnbdbackup_plus.sh --prune-then-backup -s /media/user/ai/ubuntu-20.04-server-cloudimg-amd64-disk-kvm--kub-set3-2404--claude12.qcow2 -d /media/user/backups3/rtb-ai/ --vm-name "ubuntu20.04--set3--claude12--------------------" --strategy "3:1 4:7 30:7" || echo "AI VM backup failed, continuing..."

# unused example of how to make follow symlinks
#0 3 * * * cronic /root/rsync-time-backup/rsync_tmbackup.sh --rsync-append-flags "-L" --strategy "1:1 7:1 30:7 365:30" /home/user/backup /media/user/backups/home-user/


# --strategy "1:1 7:1 30:7 365:30"
# EXPIRATION_STRATEGY="1:1 7:7 30:7 365:30" # Added
# "1:1 7:7 30:7 365:30"
# 
# Here's what that strategy means:
# 
# 1:1: For backups older than 1 day but less than 7 days, keep one backup per day.
# 7:7: For backups older than 7 days but less than 30 days, keep one backup every 7 days (weekly). This is the key change to prune last week's daily backups.
# 30:7: For backups older than 30 days but less than 365 days, continue to keep one backup every 7 days.
# 365:30: For backups older than 365 days, keep one backup every 30 days (monthly).

# "2:14 28:90 365:99999"
# 2:14: Keep daily backups for 2 days, then one every 14 days. should keep 2 daily backups.
# 28:90: For backups older than 28 days, keep one every 90 days (quarterly). keeps 2 14 day backups.
# 365:99999: For backups older than 365 days, keep only the very oldest. keeps 4 quarterly backups and then one oldest.
# total of 9?


# 
# "1:14 14:90 90:365 3650:3650"
# 1:14: Keep 2 daily backups (today & yesterday), then one every 14 days.
# 14:90: For backups older than 14 days, keep one every 90 days.
# 90:365: For backups older than 90 days, keep one every 365 days.
# 3650:3650: For backups older than 3650 days (10 years) keep only the very oldest.
