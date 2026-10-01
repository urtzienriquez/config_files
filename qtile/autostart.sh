#!/bin/sh
# $1 = qtile backend ("x11" or "wayland"), passed by hooksc.autostart.
# QTILE_NO_AUTOSTART=1 skips everything (used for nested test sessions).
[ -n "$QTILE_NO_AUTOSTART" ] && exit 0

QTILE_DIR=/home/urtzi/.config/qtile

if [ "$1" = "wayland" ]; then
    # D-Bus/systemd-activated services (dunst, ghostty, portals) must know
    # they live on Wayland, otherwise e.g. dunst tries X11 and aborts.
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE \
        XCURSOR_THEME XCURSOR_SIZE
    systemctl --user reset-failed dunst.service 2>/dev/null

    # monitor layout (autorandr equivalent) and external-monitor gamma
    pkill -x kanshi; kanshi &
    pkill -f "$QTILE_DIR/wl-gamma.py"; "$QTILE_DIR/wl-gamma.py" &

    # lock on loginctl lock-session and before suspend (xss-lock equivalent)
    pkill -x swayidle
    swayidle -w \
        lock "$QTILE_DIR/lock.sh &" \
        before-sleep 'loginctl lock-session; sleep 1' &
    pkill -f "$QTILE_DIR/smartlock.sh"; "$QTILE_DIR/smartlock.sh" &
    calcurse --daemon &
    exit 0
fi

# Back on X11: drop Wayland leftovers from a previous Wayland login, so
# D-Bus-activated apps (dunst, ghostty) don't try to use Wayland.
systemctl --user unset-environment WAYLAND_DISPLAY
dbus-update-activation-environment --systemd DISPLAY XDG_SESSION_TYPE=x11

xset s off
xset +dpms
xset dpms 0 0 0
xset s noblank
unclutter --timeout 10 &
pkill -x picom
sleep 0.5
picom -b --log-file "$HOME/.cache/picom.log" &
xss-lock --transfer-sleep-lock -- "$QTILE_DIR/lock.sh" &
"$QTILE_DIR/smartlock.sh" &
calcurse --daemon &
autorandr --change
