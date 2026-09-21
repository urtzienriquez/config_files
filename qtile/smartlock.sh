#!/bin/bash

# Debug log file path
LOG_FILE="/tmp/smartlock.log"
echo "Smartlock script initialized at $(date)" > "$LOG_FILE"

is_audio_playing() {
    # 1. Check via playerctl: Modern browsers (Firefox/Chrome) natively broadcast 
    # a "Playing" state for videos. This is completely independent of audio layers.
    if command -v playerctl >/dev/null 2>&1; then
        if playerctl status 2>/dev/null | grep -q "Playing"; then
            echo "yes"
            return
        fi
    fi

    # 2. Broad PipeWire check: Look for the word "running" anywhere in wpctl status
    # (Line limit removed so it never gets cut off by a long device list)
    if command -v wpctl >/dev/null 2>&1; then
        if wpctl status 2>/dev/null | grep -q "running"; then
            echo "yes"
            return
        fi
    fi

    # 3. Hardware Sink check: Check if the actual system speakers/outputs 
    # are actively processing a RUNNING audio stream.
    if command -v pactl >/dev/null 2>&1; then
        if pactl list short sinks 2>/dev/null | grep -q "RUNNING"; then
            echo "yes"
            return
        fi
    fi

    echo "no"
}

is_webcam_active() {
    if [ $(lsof /dev/video* 2>/dev/null | grep -v "COMMAND" | wc -l) -gt 0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

#   5 minutes idle  -> lock + blank the screen
#   15 minutes idle -> suspend
LOCK_THRESHOLD=300000
SUSPEND_THRESHOLD=900000

locked_this_idle=no

while true; do
    # Get current X11 idle time using your original fallback logic
    if command -v xprintidle >/dev/null 2>&1; then
        idle_time=$(xprintidle)
    else
        idle_time=$(xscreen -info 2>/dev/null | awk '/idle/ {print $3}')
    fi

    # Write status to log file every 10 seconds for easy troubleshooting
    echo "Current Idle: ${idle_time:-0} ms" >> "$LOG_FILE"

    if [ -n "$idle_time" ] && [ "$idle_time" -lt "$LOCK_THRESHOLD" ]; then
        locked_this_idle=no
    fi

    if [ -n "$idle_time" ] && [ "$idle_time" -gt "$SUSPEND_THRESHOLD" ]; then
        audio_active=$(is_audio_playing)
        webcam_active=$(is_webcam_active)

        echo "Suspend threshold reached! Audio: $audio_active | Webcam: $webcam_active" >> "$LOG_FILE"

        if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
            # Media is playing, reset X11 idle timer to keep it awake
            xset s reset
            locked_this_idle=no
        else
            # Genuinely idle and silent for 15 minutes -> Suspend!
            echo "Conditions met. Suspending system now." >> "$LOG_FILE"
            systemctl suspend
            locked_this_idle=no
            sleep 10
        fi
    elif [ -n "$idle_time" ] && [ "$idle_time" -gt "$LOCK_THRESHOLD" ] && [ "$locked_this_idle" = "no" ]; then
        audio_active=$(is_audio_playing)
        webcam_active=$(is_webcam_active)

        echo "Lock threshold reached! Audio: $audio_active | Webcam: $webcam_active" >> "$LOG_FILE"

        if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
            # Media is playing, reset X11 idle timer to keep it awake
            xset s reset
        else
            # Genuinely idle and silent for 5 minutes -> Lock and blank the screen
            echo "Conditions met. Locking and blanking screen now." >> "$LOG_FILE"
            loginctl lock-session
            xset dpms force off
            locked_this_idle=yes
        fi
    fi

    sleep 10
done
