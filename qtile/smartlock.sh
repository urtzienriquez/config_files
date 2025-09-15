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

# Run the checks
audio_active=$(is_audio_playing)
webcam_active=$(is_webcam_active)

# Suspend prevention logic
if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
    exit 0
fi

# Get the correct DISPLAY and XAUTHORITY from the current session
if [ -z "$DISPLAY" ]; then
    # Try to get DISPLAY from the current user's processes
    DISPLAY=$(ps -u $(whoami) -o pid,cmd | grep -E "(qtile|X|Xorg)" | head -1 | sed -n 's/.*DISPLAY=\([^ ]*\).*/\1/p')
    if [ -z "$DISPLAY" ]; then
        DISPLAY=":0"  # fallback to :0 instead of :1
    fi
fi

# Set XAUTHORITY if not already set
if [ -z "$XAUTHORITY" ]; then
    XAUTHORITY=$(find /run/user/$(id -u) -name "Xauth*" -o -name "*authority*" 2>/dev/null | head -n 1)
    if [ -z "$XAUTHORITY" ]; then
        XAUTHORITY="$HOME/.Xauthority"
    fi
fi

export DISPLAY
export XAUTHORITY

# Alternative approach: try using loginctl to get session info
if command -v loginctl >/dev/null 2>&1; then
    SESSION_ID=$(loginctl list-sessions --no-legend | grep $(whoami) | awk '{print $1}' | head -1)
    if [ -n "$SESSION_ID" ]; then
        SESSION_INFO=$(loginctl show-session "$SESSION_ID" -p Display -p Remote)
        if echo "$SESSION_INFO" | grep -q "Remote=no"; then
            DISPLAY_FROM_SESSION=$(echo "$SESSION_INFO" | grep "Display=" | cut -d'=' -f2)
            if [ -n "$DISPLAY_FROM_SESSION" ]; then
                export DISPLAY="$DISPLAY_FROM_SESSION"
            fi
        fi
    fi
fi

# Lock the screen
if command -v betterlockscreen >/dev/null 2>&1; then
    # Try different approaches to ensure proper locking
    betterlockscreen -l --off 5 &
    LOCK_PID=$!
    
    # Give it a moment to initialize
    sleep 2
    
    # Ensure all displays are properly locked
    if command -v xset >/dev/null 2>&1; then
        xset dpms force off
    fi
    
    # Wait a bit more before suspending
    sleep 1
else
    # Fallback to i3lock or xlock if available
    if command -v i3lock >/dev/null 2>&1; then
        i3lock -c 000000 &
        sleep 2
    elif command -v xlock >/dev/null 2>&1; then
        xlock &
        sleep 2
    else
        echo "No lock screen utility found!" >&2
        exit 1
    fi
fi

# Suspend the system
systemctl suspend
