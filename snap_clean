#!/bin/bash
sudo snap refresh &>/dev/null && snap list --all | awk '/disabled/{print $1, $3}' | while read name rev; do sudo echo $name >> /report; sudo snap remove "$name" --revision="$rev"; done; sudo echo $(date) >> /report
