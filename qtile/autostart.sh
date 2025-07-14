#!/bin/sh
~/.config/polybar/launch.sh &
unclutter --iddle 1 &
xautolock -time 5 -locker "/home/urtzi/.config/qtile/smartlock.sh" &
autorandr --change
feh --bg-scale ~/Pictures/linux-wallpaper.png
