#!/bin/sh
xset s off
xset -dpms
xset s noblank
unclutter --timeout 10 &
xss-lock --transfer-sleep-lock -- i3lock -c 192330 --nofork &
/home/urtzi/.config/qtile/smartlock.sh &
calcurse --daemon &
autorandr --change
