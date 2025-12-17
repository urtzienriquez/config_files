#!/bin/sh
xset dpms 0 0 0
xset -dpms
xset s 300 300
xset s noblank
unclutter --timeout 10 &
xss-lock -- "/home/urtzi/.config/qtile/smartlock.sh" &
calcurse --daemon &
autorandr --change
