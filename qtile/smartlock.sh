#!/bin/bash

# Function to check if any audio is currently playing
is_audio_playing() {
    if ! command -v pactl >/dev/null 2>&1; then
        echo "no"
        return
    fi

    pactl list sink-inputs | awk '
        BEGIN { playing=0 }
        /Corked:/ {
            if ($2 == "no") {
                playing=1
            }
        }
        END { if (playing == 1) print "yes"; else print "no" }
    '
}

# Function to check if webcam is in use
is_webcam_active() {
    webcam_usage=$(lsof /dev/video* 2>/dev/null | grep -v "COMMAND" | wc -l)
    if [ "$webcam_usage" -gt 0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# Function to get the correct display and user info
setup_display_env() {
    # Get the user who is actually logged into the graphical session
    local real_user=$(who | grep "(:0)" | awk '{print $1}' | head -1)
    if [ -z "$real_user" ]; then
        real_user=$(whoami)
    fi
    
    # Set DISPLAY if not already set
    if [ -z "$DISPLAY" ]; then
        DISPLAY=":0"
    fi
    
    # Find the correct XAUTHORITY file
    if [ -z "$XAUTHORITY" ]; then
        # Try multiple locations
        for auth_file in \
            "/home/$real_user/.Xauthority" \
            "/run/user/$(id -u $real_user)/gdm/Xauthority" \
            "/var/run/gdm3/auth-for-$real_user-*/database" \
            $(find /tmp -name "xauth-*" -user $real_user 2>/dev/null | head -1)
        do
            if [ -f "$auth_file" ] && [ -r "$auth_file" ]; then
                XAUTHORITY="$auth_file"
                break
            fi
        done
        
        # Fallback
        if [ -z "$XAUTHORITY" ]; then
            XAUTHORITY="/home/$real_user/.Xauthority"
        fi
    fi
    
    export DISPLAY
    export XAUTHORITY
    
    echo "Using DISPLAY=$DISPLAY, XAUTHORITY=$XAUTHORITY"
}

# Function to lock the screen
lock_screen() {
    echo "Attempting to lock screen..."
    
    if command -v betterlockscreen >/dev/null 2>&1; then
        # Lock without suspend timeout initially
        betterlockscreen -l &
        local lock_pid=$!
        
        # Wait for betterlockscreen to fully initialize
        sleep 3
        
        # Check if the lock process is still running
        if ! kill -0 $lock_pid 2>/dev/null; then
            echo "betterlockscreen failed to start properly"
            return 1
        fi
        
        echo "Screen locked successfully"
        return 0
        
    elif command -v i3lock >/dev/null 2>&1; then
        i3lock -c 000000 &
        sleep 2
        echo "Screen locked with i3lock"
        return 0
        
    elif command -v xlock >/dev/null 2>&1; then
        xlock &
        sleep 2
        echo "Screen locked with xlock"
        return 0
        
    else
        echo "No lock screen utility found!" >&2
        return 1
    fi
}

# Main execution
main() {
    echo "Smart lock script started"
    
    # Run the checks
    audio_active=$(is_audio_playing)
    webcam_active=$(is_webcam_active)
    
    echo "Audio active: $audio_active"
    echo "Webcam active: $webcam_active"
    
    # Suspend prevention logic
    if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
        echo "Audio or webcam active, not locking/suspending"
        exit 0
    fi
    
    # Setup display environment
    setup_display_env
    
    # Test if we can connect to X server
    if ! xset q >/dev/null 2>&1; then
        echo "Cannot connect to X server, trying alternative display setup..."
        # Try loginctl approach
        if command -v loginctl >/dev/null 2>&1; then
            SESSION_ID=$(loginctl list-sessions --no-legend | awk '{print $1}' | head -1)
            if [ -n "$SESSION_ID" ]; then
                SESSION_DISPLAY=$(loginctl show-session "$SESSION_ID" -p Display --value)
                if [ -n "$SESSION_DISPLAY" ]; then
                    export DISPLAY="$SESSION_DISPLAY"
                    echo "Using display from loginctl: $DISPLAY"
                fi
            fi
        fi
    fi
    
    # Final test
    if ! xset q >/dev/null 2>&1; then
        echo "Still cannot connect to X server, aborting lock" >&2
        exit 1
    fi
    
    # Lock the screen first
    if lock_screen; then
        echo "Screen locked, waiting before suspend..."
        # Give the lock screen more time to fully activate
        sleep 5
        
        # Turn off displays
        if command -v xset >/dev/null 2>&1; then
            xset dpms force off
        fi
        
        # Additional wait to ensure lock is solid
        sleep 2
        
        # Now suspend
        echo "Suspending system..."
        systemctl suspend
    else
        echo "Failed to lock screen, not suspending for security"
        exit 1
    fi
}

# Run main function
main "$@"
