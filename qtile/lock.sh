#!/bin/bash

# Locker used by xss-lock (X11) / swayidle (Wayland): turn off the keyboard
# backlight while locked and restore it as soon as the locker exits, whatever
# triggered the lock.
KBD_LED="/sys/class/leds/msiacpi::kbd_backlight/brightness"

pgrep -x i3lock >/dev/null || pgrep -x swaylock >/dev/null && exit 0

saved=$(cat "$KBD_LED" 2>/dev/null)
{ [ -z "$saved" ] || [ "$saved" = 0 ]; } && saved=3
echo 0 > "$KBD_LED" 2>/dev/null

if [ -n "$WAYLAND_DISPLAY" ]; then
    swaylock -c 192330
else
    i3lock -c 192330 --nofork
fi

echo "$saved" > "$KBD_LED" 2>/dev/null
