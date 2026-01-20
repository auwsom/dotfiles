#!/bin/bash
set -m
# ~/.konsole/watcher.sh

# Watches the konsole qdbus messages and saves session state changes so they can be restored easily
# https://docs.kde.org/trunk5/en/applications/konsole/command-line-options.html

# Configuration
COMMAND=''
WATCH_INTERVAL_SECONDS=15
SAVEFILE_TERMINAL="${HOME}/current-tabs"

# Restore if asked to
if [ "$1" = "restore" ] ; then
    echo "Restoring..."
    konsole --tabs-from-file ${SAVEFILE_TERMINAL} -e 'bash -c exit'&
fi
# Function to get the current sessions and write them to a file
function getSessions {
    #pgrep "konsole" > /dev/pts/6
    pid=$(pgrep "konsole" -u $USER | awk '{print $1}')
    #echo test1 $USER $pid  f > /dev/pts/6
    pid=$(pgrep "konsole" -u $USER )
    #echo test2 $USER $pid  f > /dev/pts/6

    local SESSIONS=$(qdbus org.kde.konsole-$pid | grep /Sessions/)
    if [[ ${SESSIONS} ]] ; then
       echo "# Most recent session list " $(date) >| ${SAVEFILE_TERMINAL}

       for i in ${SESSIONS}; do
       local FORMAT=$(qdbus org.kde.konsole-$pid $i tabTitleFormat 0)
       local PROCESSID=$(qdbus org.kde.konsole-$pid $i processId)
       local CWD=$(pwdx ${PROCESSID} | sed -e "s/^[0-9]*: //")
       #echo $FORMAT $PROCESSID > /dev/pts/6

       if [[ $(pgrep --parent ${PROCESSID}) ]] ; then
           CHILDPID=$(pgrep --parent ${PROCESSID})
           COMMAND=$(ps -p ${CHILDPID} -o args=)
       fi 
       #echo $FORMAT $PROCESSID $CHILDPID $COMMAND > /dev/pts/6
       #echo $FORMAT $PROCESSID > /dev/pts/6
       echo "workdir: ${CWD};; title: ${FORMAT};; command:${COMMAND}" >> ${SAVEFILE_TERMINAL}
       COMMAND=''
       done
    fi
}

#Update the Konsole sessions every WATCH_INTERVAL_SECONDS seconds
while true; do sleep ${WATCH_INTERVAL_SECONDS}; getSessions; done &

