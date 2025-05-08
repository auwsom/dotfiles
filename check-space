#!/bin/bash
CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g') ; THRESHOLD=95; if [ "$CURRENT" -gt "$THRESHOLD" ] ; then mail -s "Disk Space Alert Used: $CURRENT" root <<< $(hostname); fi
