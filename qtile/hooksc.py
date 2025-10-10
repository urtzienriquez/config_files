from libqtile import qtile
from libqtile import hook
import subprocess
import os
import time


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
    subprocess.call([home + "/.config/qtile/autostart.sh"])


@hook.subscribe.client_managed
def auto_show_screen(window):
    # check whether group is visible on any screen right now
    # qtile.groups_map['<somegroup>'].screen is None in case it is currently not shown on any screen
    visible_groups = [
        group_name for group_name, group in qtile.groups_map.items() if group.screen
    ]
    if window.group.name not in visible_groups:
        window.group.cmd_toscreen()


# @hook.subscribe.suspend
# def lock_before_suspend():
#     subprocess.run(["betterlockscreen", "-l"])


def restart_polybar():
    """Kill existing Polybar processes and restart them"""
    try:
        subprocess.run(["pkill", "polybar"], check=False)
        time.sleep(0.5)
        home = os.path.expanduser("~")
        subprocess.Popen([home + "/.config/polybar/launch.sh"], shell=True)
    except Exception as e:
        print(f"Error restarting polybar: {e}")


@hook.subscribe.screen_change
def on_screen_change(event):
    restart_polybar()


@hook.subscribe.startup_complete
def startup_complete():
    time.sleep(1)
    restart_polybar()


@hook.subscribe.restart
def on_restart():
    restart_polybar()


@hook.subscribe.client_managed
def center_sized_floating_window(window):
    if window.floating:
        center_these = ["ranger", "calendar"]
        wm_class = window.get_wm_class()

        if wm_class and any(cls in wm_class for cls in center_these):
            # Use qtile's idle mechanism to center after window is fully sized
            qtile.call_later(0.1, lambda: _center_window(window))


def _center_window(window):
    try:
        screen = window.group.screen or qtile.current_screen
        x = screen.x + (screen.width - window.width) // 2
        y = screen.y + (screen.height - window.height) // 2
        window.tweak_float(x=x, y=y)
    except:
        pass  # Window might have been closed
