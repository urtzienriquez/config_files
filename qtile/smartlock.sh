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

# 5 minutes = 300000 ms
IDLE_THRESHOLD=300000

while true; do
    # Get current X11 idle time using your original fallback logic
    if command -v xprintidle >/dev/null 2>&1; then
        idle_time=$(xprintidle)
    else
        idle_time=$(xscreen -info 2>/dev/null | awk '/idle/ {print $3}')
    fi

    # Write status to log file every 10 seconds for easy troubleshooting
    echo "Current Idle: ${idle_time:-0} ms" >> "$LOG_FILE"

    if [ -n "$idle_time" ] && [ "$idle_time" -gt "$IDLE_THRESHOLD" ]; then
        audio_active=$(is_audio_playing)
        webcam_active=$(is_webcam_active)

        echo "Threshold reached! Audio: $audio_active | Webcam: $webcam_active" >> "$LOG_FILE"

        if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
            # Media is playing, reset X11 idle timer to keep it awake
            xset s reset
        else
            # System is genuinely idle and silent -> Suspend!
            echo "Conditions met. Suspending system now." >> "$LOG_FILE"
            systemctl suspend
            sleep 10 
        fi
    fi
    
    sleep 10
done
