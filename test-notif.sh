#!/bin/bash
sudo -u user DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u user gnome-session | head -n1)/environ | tr "\0" "\n" | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-) notify-send --urgency=critical --expire-time=0 "test-notif"
