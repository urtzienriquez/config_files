#!/bin/bash

# Debug log file path
LOG_FILE="/tmp/smartlock.log"
[ -z "$1" ] && echo "Smartlock script initialized at $(date)" > "$LOG_FILE"

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

# Idle action: lock + blank only, never auto-suspend (real suspend via
# lid-close or `systemctl suspend`). swayidle fires after 5 min idle and runs
# this script with --idle; that waiter holds off while media/webcam is active,
# then locks. Any input (resume) kills the waiter.
if [ "$1" = "--idle" ]; then
    while [ "$(is_audio_playing)" = "yes" ] || [ "$(is_webcam_active)" = "yes" ]; do
        sleep 10
    done
    echo "Conditions met. Locking and blanking screen now." >> "$LOG_FILE"
    loginctl lock-session  # lock.sh handles the keyboard backlight
    sleep 1
    wlopm --off '*'
    exit 0
fi

# Any input after the timeout: stop a pending waiter and turn the outputs back
# on. Done here rather than inline in swayidle's resume: swayidle runs that
# through `sh -c "..."`, whose own command line would contain
# "smartlock.sh --idle", so the pkill would kill that shell before wlopm ran.
if [ "$1" = "--resume" ]; then
    pkill -f "smartlock.sh --idle"
    wlopm --on '*'
    exit 0
fi

swayidle -w \
    timeout 300 "$0 --idle &" \
    resume "$0 --resume" &
swayidle_pid=$!
# toggle_smartlock kills this script by name; take swayidle down with it
trap 'kill $swayidle_pid 2>/dev/null; exit 0' TERM INT
wait $swayidle_pid
