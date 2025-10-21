#!/bin/sh
~/.config/polybar/launch.sh &
xset dpms 0 0 0
xset -dpms
xset s 300 300
xset s noblank
unclutter --timeout 10 &
# xautolock -time 5 -locker "/home/urtzi/.config/qtile/smartlock.sh" &
xss-lock -- "/home/urtzi/.config/qtile/smartlock.sh" &
autorandr --change
