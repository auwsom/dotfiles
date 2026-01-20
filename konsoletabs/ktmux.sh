#!/bin/bash

# Get all tmux session names
sessions=$(tmux list-sessions -F '#S')

port=8080

# Loop through each session and open in a new Firefox tab
for session in $sessions; do
    ttyd -W -p $port tmux attach-session -t "$session" &
    port=$((port + 1))
    # Open the session in a new Firefox tab
    firefox --new-tab "http://localhost:$port" &
done

