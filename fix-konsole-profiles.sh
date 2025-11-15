#!/bin/bash
# Function to set profiles for all tabs in a Konsole window
# Usage: set_konsole_profiles <window_dbus_id> <profile_name>

set_konsole_profiles() {
    local window_id="$1"
    local profile_name="$2"
    
    # Get all sessions for this window
    local sessions=($(DISPLAY=:0 qdbus "org.kde.konsole-$window_id" | grep "/Sessions/[0-9]" | sort -V))
    
    echo "Setting profile '$profile_name' for window $window_id..."
    
    for session in "${sessions[@]}"; do
        echo "  Setting $session to $profile_name"
        DISPLAY=:0 qdbus "org.kde.konsole-$window_id" "$session" org.kde.konsole.Session.setProfile "$profile_name"
    done
}

# Get all Konsole windows
konsole_windows=($(DISPLAY=:0 qdbus | grep "org.kde.konsole-" | sed 's/org\.kde\.konsole-//' | sort -n))

echo "Found Konsole windows: ${konsole_windows[@]}"

# Set profiles for each window
for window_id in "${konsole_windows[@]}"; do
    # Determine profile based on window content or position
    # For our setup: first window (254809) uses Regular User, others use aimgr
    if [[ "$window_id" == "254809" ]]; then
        set_konsole_profiles "$window_id" "Regular User"
    else
        set_konsole_profiles "$window_id" "aimgr"
    fi
done

echo "Profile setting complete!"
