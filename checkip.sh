#!/bin/bash
set -Cex; shellcheck "$0" 

if ! [[ -e /ipcheck ]];then touch /ipcheck;fi 
ip=$(\curl ifconfig.me); if [[ $(cat /ipcheck) != "$ip" ]]; then echo "$ip" >| /ipcheck; mail -s "ip change $(hostname)" "$(cat ~/.env/EMAIL)" <<< "msg"; fi
