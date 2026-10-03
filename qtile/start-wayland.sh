#!/bin/bash
# Launcher for the "Qtile Wayland" session (see qtile-wayland.desktop).
# Uses a separate venv qtile (0.37, C Wayland backend) linked against a
# user-prefix wlroots 0.20 (~/.local/opt/wlroots-0.20, built by wayland/build-qtile-wayland.sh).
# Fallback: ~/.local/share/qtile-wl (qtile 0.31 / pywlroots 0.17).

QTILE_WL="$HOME/.local/share/qtile-wl-0.37/bin/qtile"
LOG="$HOME/.local/state/qtile-wayland.log"
mkdir -p "$(dirname "$LOG")"

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=qtile
export XDG_SESSION_DESKTOP=qtile

# Hybrid GPU: run the compositor on the Intel iGPU (card numbers can swap
# between boots, so resolve it from the PCI path).
export WLR_DRM_DEVICES="$(readlink -f /dev/dri/by-path/pci-0000:00:02.0-card)"
export WLR_NO_HARDWARE_CURSORS=1

# Same cursor as GNOME (gsettings), also for XWayland apps
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

# Prefer native Wayland in toolkits, falling back to XWayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland;xcb"
export GDK_BACKEND="wayland,x11"
export SDL_VIDEODRIVER="wayland,x11"
export _JAVA_AWT_WM_NONREPARENTING=1

# No input-method daemon: the Compose key (Menu, see config.py) handles accents
export GTK_IM_MODULE=simple
export QT_IM_MODULE=compose
export XMODIFIERS=@im=none

# Python tracebacks on crashes go to $LOG; qtile's own log goes next to it
# (appended, so a crash's output survives the next login)
export PYTHONFAULTHANDLER=1
echo "===== session start $(date '+%F %T') =====" >>"$LOG"
exec "$QTILE_WL" start -b wayland -p "$HOME/.local/state/qtile-wayland-qtile.log" >>"$LOG" 2>&1
