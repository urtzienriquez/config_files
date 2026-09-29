import os
import subprocess

from libqtile.dgroups import simple_key_binder

# Render Ghostty (and other EGL apps) on the Intel iGPU instead of the NVIDIA dGPU.
# Also exported to D-Bus so a D-Bus-activated Ghostty picks it up.
os.environ["__EGL_VENDOR_LIBRARY_FILENAMES"] = "/usr/share/glvnd/egl_vendor.d/50_mesa.json"
subprocess.run(
    ["dbus-update-activation-environment", "__EGL_VENDOR_LIBRARY_FILENAMES"],
    check=False,
)

from keybindsc import keys, mod
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
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
