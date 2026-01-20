#!/bin/bash
while true; do
    # Prompt for command input
    read -p "$ " cmd
    
    # Allow exit with 'exit' command
    if [[ "$cmd" == "exit" ]]; then
        echo "Exiting..."
        break
    fi
    
    # Check if command is incomplete
    if ! bash -n <<< "$cmd" 2>/dev/null; then
        echo "Error: Incomplete command"
    else
        bash -c "$cmd"
    fi
done

