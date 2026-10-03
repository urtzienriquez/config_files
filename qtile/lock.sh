#!/bin/bash

# Locker used by swayidle: turn off the keyboard backlight while locked and
# restore it as soon as swaylock exits, whatever triggered the lock.
KBD_LED="/sys/class/leds/msiacpi::kbd_backlight/brightness"

pgrep -x swaylock >/dev/null && exit 0

saved=$(cat "$KBD_LED" 2>/dev/null)
{ [ -z "$saved" ] || [ "$saved" = 0 ]; } && saved=3
echo 0 > "$KBD_LED" 2>/dev/null

swaylock -c 192330

echo "$saved" > "$KBD_LED" 2>/dev/null
# in case the idle lock (smartlock.sh) left the outputs off
wlopm --on '*'
