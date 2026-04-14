#!/bin/sh
xset dpms 0 0 0
xset -dpms
xset s 300 300
xset s noblank
unclutter --timeout 10 &
xss-lock -- "/home/urtzi/.config/qtile/smartlock.sh" &
calcurse --daemon &
autorandr --change
xrandr --output HDMI-1 --gamma 0.8:0.8:0.8 --brightness 0.8
