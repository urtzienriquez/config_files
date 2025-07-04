from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
import subprocess
import os
from libqtile import hook

mod = "mod4"
alt = "mod1"
terminal = "ghostty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between monitors
    Key([mod], "space", lazy.next_screen(), desc="Next monitor"),
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "w", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    # session management
    Key([mod, "control"], "q", lazy.shutdown(), desc="Logout Qtile"),
    Key([mod, alt, "shift"], "r", lazy.spawn("systemctl reboot"), desc="Reboot"),
    Key([mod, alt, "shift"], "s", lazy.spawn("systemctl poweroff"), desc="Shutdown"),
    # volume
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master 5%-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master 5%+")),
    Key([], "XF86AudioMute", lazy.spawn("amixer sset Master 1+ toggle")),
    # Brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl -c backlight set 2%+")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl -c backlight set 2%-")),
    # mouseless pointer
    Key([mod], "d", lazy.spawn("warpd --hint")),
    Key([mod, "shift"], "d", lazy.spawn("warpd --hint2")),
    Key([mod], "c", lazy.spawn("warpd --normal")),
    Key([mod], "g", lazy.spawn("warpd --grid")),
    Key([mod], "s", lazy.spawn("warpd --screen")),
    # Launchers
    Key([alt], "k", lazy.window.kill(), desc="Kill focused window"),
    Key([alt], "r", lazy.spawn("rofi -modi drun,run -show drun")),
    Key([alt], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod, alt], "Return", lazy.spawn("gnome-terminal")),
    Key([alt], "s", lazy.spawn("gnome-control-center")),
    Key([alt], "v", lazy.spawn("ghostty -e /opt/nvim/bin/nvim")),
    Key([alt], "a", lazy.spawn("ghostty -e calcurse")),
    Key([alt], "n", lazy.spawn("jupyter-lab")),
    Key([alt], "f", lazy.spawn("ghostty -e ranger")),
    Key([alt], "w", lazy.spawn("libreoffice25.2 --writer")),
    Key([alt], "b", lazy.spawn("librewolf")),
    Key([alt], "q", lazy.spawn("qutebrowser")),
    Key(
        [alt],
        "y",
        lazy.spawn(
            "qutebrowser --basedir /home/urtzi/.config/quteyoutube --qt-arg name youtube"
        ),
    ),
    Key([alt], "z", lazy.spawn("zotero")),
    Key([alt], "i", lazy.spawn("inkscape")),
    Key([alt], "g", lazy.spawn("gimp")),
    Key([alt], "o", lazy.spawn("zoom")),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

## Figuring out groups

groups = [Group(i) for i in "123456789"]

# groups = [
#     Group("a"),
#     Group("b"),
#     Group("c", matches=[Match(wm_class=["qutebrowser"])]),
# ]

# groups = [
#     Group("Web", matches=[Match(wm_class=["qutebrowser"])]),
#     Group("Code"),
#     Group("Notes"),
#     Group("Music"),
#     Group("Social"),
# ]
#
# keypad = {
#     1: "KP_End",
#     2: "KP_Down",
#     3: "KP_Next",
#     4: "KP_Left",
#     5: "KP_Begin",
# }
#
# for index, group in enumerate(groups, start=1):
#     _keys = [str(index), keypad[index]]
#     for key in _keys:
#         keys.extend(
#             [
#                 Key(
#                     [mod],
#                     key,
#                     lazy.group[group.name].toscreen(),
#                     desc=f"Switch to group {index}",
#                 ),
#                 Key(
#                     [mod, "control"],
#                     key,
#                     lazy.window.togroup(group.name),
#                     desc=f"Move focused window to group {index}",
#                 ),
#                 Key(
#                     [mod, "shift"],
#                     key,
#                     lazy.window.togroup(group.name, switch_group=True),
#                     desc=f"Move focused window and switch to group {index}.",
#                 ),
#             ]
#         )

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

right_screen = Screen(
    top=bar.Bar(
        [
            widget.CurrentLayout(),
            widget.GroupBox(),
            widget.Prompt(),
            # widget.Sep(linewidth=0, padding=1000),
            widget.WindowName(),
            widget.Chord(
                chords_colors={
                    "launch": ("#ff0000", "#ffffff"),
                },
                name_transform=lambda name: name.upper(),
            ),
            # widget.Systray(),
            widget.Wlan(
                format="{essid} {percent:2.0%}",
                interface="wlo1",
                ethernet_interface="enp4s0",
                use_ethernet=True,
            ),
            widget.Backlight(fmt="Br: {}", backlight_name="intel_backlight"),
            widget.PulseVolume(fmt="Vol: {}"),
            widget.Clock(format="%I:%M %p"),
            widget.Battery(format="Bat: {percent:2.0%}"),
            widget.QuickExit(),
        ],
        24,
    ),
    # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
    # By default we handle these events delayed to already improve performance, however your system might still be struggling
    # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
    # x11_drag_polling_rate = 60,
)
left_screen = Screen(
    top=bar.Bar(
        [
            widget.CurrentLayout(),
            widget.GroupBox(),
            widget.Prompt(),
            # widget.Sep(linewidth=0, padding=1000),
            widget.WindowName(),
            widget.Chord(
                chords_colors={
                    "launch": ("#ff0000", "#ffffff"),
                },
                name_transform=lambda name: name.upper(),
            ),
            # widget.Systray(),
            widget.Wlan(
                format="{essid} {percent:2.0%}",
                interface="wlo1",
                ethernet_interface="enp4s0",
                use_ethernet=True,
            ),
            widget.Backlight(fmt="Br: {}", backlight_name="intel_backlight"),
            widget.PulseVolume(fmt="Vol: {}"),
            widget.Clock(format="%I:%M %p"),
            widget.Battery(format="Bat: {percent:2.0%}"),
            widget.QuickExit(),
        ],
        24,
    ),
    # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
    # By default we handle these events delayed to already improve performance, however your system might still be struggling
    # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
    # x11_drag_polling_rate = 60,
)
amt_screens = 2
screens = [right_screen, left_screen]
reconfigure_screens = False

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"


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
