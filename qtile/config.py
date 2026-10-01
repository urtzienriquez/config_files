import os
import subprocess

from libqtile.backend.wayland import InputConfig
from libqtile.dgroups import simple_key_binder

# Render Ghostty (and other EGL apps) on the Intel iGPU instead of the NVIDIA dGPU.
# Also exported to D-Bus so a D-Bus-activated Ghostty picks it up.
os.environ["__EGL_VENDOR_LIBRARY_FILENAMES"] = "/usr/share/glvnd/egl_vendor.d/50_mesa.json"
subprocess.run(
    ["dbus-update-activation-environment", "__EGL_VENDOR_LIBRARY_FILENAMES"],
    check=False,
)

from keybindsc import keys, mod, KB_OPTIONS
from groupsc import groups
from layoutsc import layouts, floating_layout
from mousec import mouse
from screensc import screens
from hooksc import (
    dbus_register,
    autostart,
    auto_show_screen,
)


dgroups_app_rules = []  # type: list
follow_mouse_focus = False
bring_front_click = False
floats_kept_above = True
# no warping to the center of focused windows (ghostty's command palette is
# there); hooksc.follow_screen only moves the pointer across monitors
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
# Wayland equivalents of the setxkbmap line in .xprofile and of
# /etc/X11/xorg.conf.d/40-libinput.conf (touchpads only, not the trackball)
wl_input_rules = {
    "type:keyboard": InputConfig(kb_layout="us", kb_options=KB_OPTIONS),
    "type:touchpad": InputConfig(tap=True, natural_scroll=True),
}
wl_xcursor_theme = "Adwaita"
wl_xcursor_size = 24
# No unclutter-style cursor hiding on Wayland: qtile 0.37's
# core.hide_cursor/unhide_cursor restores a possibly-freed cursor surface
# (use-after-free in qw/cursor.c) and crashes the session.
# Explicitly empty: a config reload keeps settings the config doesn't define.
idle_timers = []  # type: list
wmname = "LG3D"
