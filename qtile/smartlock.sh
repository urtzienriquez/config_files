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

# Prepare environment variables for graphical lock
export DISPLAY=:1
export XAUTHORITY=$(find /run/user/$(id -u) -name "Xauthority" | head -n 1)

# Lock the screen in background
if command -v betterlockscreen >/dev/null 2>&1; then
    betterlockscreen -l &
    sleep 1
fi

# Now suspend
systemctl suspend
