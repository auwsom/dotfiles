#!/bin/bash
if [ ! $(head -1 /etc/passwd | grep nologin) ]; then echo mail -s "not nologin $(hostname)" $EMAIL "message"; fi
