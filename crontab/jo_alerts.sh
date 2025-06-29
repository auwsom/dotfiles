#!/bin/bash

alert=$(journalctl --since="$(date '+%F %T' -d '1 hour ago')" --priority=crit --quiet)
if [[ -n "$alert" ]]; then mail -s "jo_alerts: $(hostname)" $(cat /root/.env/EMAIL) <<< $(echo "$alert"); fi

