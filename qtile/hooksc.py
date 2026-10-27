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
    # Don't block: qtile is the compositor, so while this hook runs no
    # client (XWayland, portals...) can connect -> autostart would deadlock
    subprocess.Popen([home + "/.config/qtile/autostart.sh"])


@hook.subscribe.client_managed
def auto_show_screen(window):
    # check whether group is visible on any screen right now
    # qtile.groups_map['<somegroup>'].screen is None in case it is currently not shown on any screen
    visible_groups = [
        group_name for group_name, group in qtile.groups_map.items() if group.screen
    ]
    if window.group.name not in visible_groups:
        window.group.toscreen()


# Floating popups opened at a fraction of the screen (width, height).
# Terminal popups match by title, apps by wm_class.
POPUP_TITLES = {"fzf-nova", "calendar", "yazi", "qeditor"}
POPUP_SIZE = (0.5, 0.5)
# GNOME Settings otherwise restores its own saved (wide/maximized) size
POPUP_CLASSES = {
    "org.gnome.Settings": (0.45, 0.75),
}


@hook.subscribe.client_managed
def size_popups(window):
    if not window.floating:
        return
    if window.name in POPUP_TITLES:
        size = POPUP_SIZE
    else:
        wm_class = window.get_wm_class() or []
        size = next((POPUP_CLASSES[c] for c in wm_class if c in POPUP_CLASSES), None)
        if size is None:
            return
    screen = window.group.screen or qtile.current_screen
    window.set_size_floating(int(screen.width * size[0]), int(screen.height * size[1]))
    window.center()


# Apps that ask to be maximized (also after mapping); qtile always honors
# that on Wayland, which takes them out of the tiling layout. There is no
# hook for the request, so wrap the backend's handler
TILE_CLASSES = {
    "ai.storyteller.photocraft",
    "ai.storyteller.wordcraft",
    "ai.storyteller.vectorcraft",
}


def _wants_tiling(window):
    return any(c in TILE_CLASSES for c in window.get_wm_class() or [])


try:
    from libqtile.backend.wayland.window import Window as WlWindow
except ImportError:  # X11 session
    WlWindow = None

if WlWindow is not None:
    # keep the real handler across config reloads
    if not hasattr(WlWindow, "_orig_request_maximize"):
        WlWindow._orig_request_maximize = WlWindow.handle_request_maximize

    def _handle_request_maximize(self, maximize):
        if _wants_tiling(self):
            return False
        return self._orig_request_maximize(maximize)

    WlWindow.handle_request_maximize = _handle_request_maximize


# in case the request came before the app_id was known
@hook.subscribe.client_managed
def tile_maximized_apps(window):
    if _wants_tiling(window) and window.maximized:
        window.disable_floating()


@hook.subscribe.client_name_updated
def shorten_pdf_names(window):
    if window.name and ".pdf" in window.name.lower():
        window.name = os.path.basename(window.name)
