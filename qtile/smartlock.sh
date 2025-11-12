#!/bin/bash

# --- Check if audio is playing ---
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

# --- Check if webcam is active ---
is_webcam_active() {
    webcam_usage=$(lsof /dev/video* 2>/dev/null | grep -v "COMMAND" | wc -l)
    if [ "$webcam_usage" -gt 0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

main() {
    audio_active=$(is_audio_playing)
    webcam_active=$(is_webcam_active)

    echo "Audio active: $audio_active, Webcam active: $webcam_active"

    # Prevent suspend/lock if media is active
    if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
        echo "Skipping suspend: audio or webcam in use"
        # Reset the screensaver to deactivate it, so xss-lock will trigger again
        xset s reset
        xset s activate  # Force reactivation to reset xss-lock's state
        xset s reset     # Then reset again to start the timer fresh
        exit 0
    fi

    # Media is not active, proceed with suspend
    echo "Suspending system..."
    systemctl suspend
}

main "$@"
