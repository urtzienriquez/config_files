#!/bin/sh
# Run by hooksc.autostart at qtile startup (and on config reloads).
# QTILE_NO_AUTOSTART=1 skips everything (used for nested test sessions).
[ -n "$QTILE_NO_AUTOSTART" ] && exit 0

QTILE_DIR=/home/urtzi/.config/qtile

# D-Bus/systemd-activated services (dunst, ghostty, portals) must know they
# live on Wayland, otherwise e.g. dunst tries X11 and aborts.
dbus-update-activation-environment --systemd \
    WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE \
    XCURSOR_THEME XCURSOR_SIZE
systemctl --user reset-failed dunst.service 2>/dev/null

# monitor layout (~/.config/kanshi/config) and external-monitor gamma
pkill -x kanshi; kanshi &
pkill -f "$QTILE_DIR/wl-gamma.py"; "$QTILE_DIR/wl-gamma.py" &

# lock on loginctl lock-session and before suspend
pkill -x swayidle
swayidle -w \
    lock "$QTILE_DIR/lock.sh &" \
    before-sleep 'loginctl lock-session; sleep 1' &
pkill -f "$QTILE_DIR/smartlock.sh"; "$QTILE_DIR/smartlock.sh" &
calcurse --daemon &
