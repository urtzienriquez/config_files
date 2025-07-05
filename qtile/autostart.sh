#!/bin/sh
# nm-applet &
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# pasystray &
# xcompmgr -c &
~/.config/polybar/launch.sh &
unclutter --iddle 1 &
autorandr --change
feh --bg-scale ~/Pictures/linux-wallpaper.png
