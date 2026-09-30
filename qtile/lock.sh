#!/bin/bash

# Locker used by xss-lock: turn off the keyboard backlight while locked and
# restore it as soon as i3lock exits, whatever triggered the lock.
KBD_LED="/sys/class/leds/msiacpi::kbd_backlight/brightness"

saved=$(cat "$KBD_LED" 2>/dev/null)
{ [ -z "$saved" ] || [ "$saved" = 0 ]; } && saved=3
echo 0 > "$KBD_LED" 2>/dev/null

i3lock -c 192330 --nofork

echo "$saved" > "$KBD_LED" 2>/dev/null
