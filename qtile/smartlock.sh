#!/bin/bash

# Debug log file path
LOG_FILE="/tmp/smartlock.log"
[ "$1" = "--idle" ] || echo "Smartlock script initialized at $(date)" > "$LOG_FILE"

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

# Wayland: no idle-time polling, so swayidle fires after 5 min idle and runs
# this script with --idle; that waiter holds off while media/webcam is active,
# then locks. Any input (resume) kills the waiter.
if [ "$1" = "--idle" ]; then
    while [ "$(is_audio_playing)" = "yes" ] || [ "$(is_webcam_active)" = "yes" ]; do
        sleep 10
    done
    echo "Conditions met. Locking and blanking screen now." >> "$LOG_FILE"
    loginctl lock-session
    sleep 1
    wlopm --off '*'  # = xset dpms force off
    exit 0
fi

if [ -n "$WAYLAND_DISPLAY" ]; then
    swayidle -w \
        timeout 300 "$0 --idle &" \
        resume "pkill -f 'smartlock.sh --idle'; wlopm --on '*'" &
    swayidle_pid=$!
    # toggle_smartlock kills this script by name; take swayidle down with it
    trap 'kill $swayidle_pid 2>/dev/null; exit 0' TERM INT
    wait $swayidle_pid
    exit 0
fi

# idle action: lock+blank only, never auto-suspend.
# Real suspend via lid-close or by running `systemctl suspend`
IDLE_THRESHOLD=300000
dimmed=no

while true; do
    # Get current X11 idle time using your original fallback logic
    if command -v xprintidle >/dev/null 2>&1; then
        idle_time=$(xprintidle)
    else
        idle_time=$(xscreen -info 2>/dev/null | awk '/idle/ {print $3}')
    fi

    # Write status to log file every 10 seconds for easy troubleshooting
    echo "Current Idle: ${idle_time:-0} ms" >> "$LOG_FILE"

    if [ -n "$idle_time" ] && [ "$idle_time" -lt "$IDLE_THRESHOLD" ]; then
        dimmed=no
    fi

    if [ -n "$idle_time" ] && [ "$idle_time" -gt "$IDLE_THRESHOLD" ]; then
        audio_active=$(is_audio_playing)
        webcam_active=$(is_webcam_active)

        echo "Threshold reached! Audio: $audio_active | Webcam: $webcam_active" >> "$LOG_FILE"

        if [ "$audio_active" = "yes" ] || [ "$webcam_active" = "yes" ]; then
            # Media is playing, reset X11 idle timer to keep it awake
            xset s reset
        elif [ "$dimmed" = "no" ]; then
            # Genuinely idle and silent -> Lock and blank the screen
            # (lock.sh handles the keyboard backlight)
            echo "Conditions met. Locking and blanking screen now." >> "$LOG_FILE"
            loginctl lock-session
            xset dpms force off
            dimmed=yes
        fi
    fi

    sleep 10
done
