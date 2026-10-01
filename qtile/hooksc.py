from libqtile import qtile
from libqtile import hook
import subprocess
import os


@hook.subscribe.startup
def dbus_register():
    id = os.environ.get("DESKTOP_AUTOSTART_ID")
    if not id:
        return
    subprocess.Popen(
        [
            "dbus-send",
            "--session",
            "--print-reply",
            "--dest=org.gnome.SessionManager",
            "/org/gnome/SessionManager",
            "org.gnome.SessionManager.RegisterClient",
            "string:qtile",
            "string:" + id,
        ]
    )


@hook.subscribe.startup
def autostart():
    home = os.path.expanduser("~")
    cmd = [home + "/.config/qtile/autostart.sh", qtile.core.name]
    if qtile.core.name == "wayland":
        # Don't block: qtile is the compositor, so while this hook runs no
        # client (XWayland, portals...) can connect -> autostart would deadlock
        subprocess.Popen(cmd)
    else:
        subprocess.call(cmd)


@hook.subscribe.client_managed
def auto_show_screen(window):
    # check whether group is visible on any screen right now
    # qtile.groups_map['<somegroup>'].screen is None in case it is currently not shown on any screen
    visible_groups = [
        group_name for group_name, group in qtile.groups_map.items() if group.screen
    ]
    if window.group.name not in visible_groups:
        window.group.toscreen()


@hook.subscribe.client_name_updated
def shorten_pdf_names(window):
    if window.name and ".pdf" in window.name.lower():
        window.name = os.path.basename(window.name)


WARP_INSET = 30  # px from the window's top and right edges


@hook.subscribe.client_focus
def warp_to_top_right(win):
    # put the pointer near the top-right corner instead of cursor_warp's center
    x = win.width - WARP_INSET
    y = WARP_INSET
    if qtile.core.name == "wayland":
        qtile.core.warp_pointer(win.x + x, win.y + y)  # absolute coords
    else:
        win.window.warp_pointer(x, y)  # relative to the window
