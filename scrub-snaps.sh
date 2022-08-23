#!/bin/bash
#echo "@reboot /home/user/autostart-scripts/snap_refresh" >> /var/spool/cron/crontabs/root
snap refresh
# This script will remove disabled snap revisions.
set -eu

LANG=C snap list --all | awk '/disabled/{print $1, $3}' |
    while read name rev; do
        snap remove "$name" --revision="$rev"
    done
