#!/bin/sh
xset s off
xset +dpms
xset dpms 0 0 0
xset s noblank
unclutter --timeout 10 &
pkill -x picom
sleep 0.5
picom -b --log-file "$HOME/.cache/picom.log" &
xss-lock --transfer-sleep-lock -- i3lock -c 192330 --nofork &
/home/urtzi/.config/qtile/smartlock.sh &
calcurse --daemon &
autorandr --change
