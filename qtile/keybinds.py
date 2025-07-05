from libqtile import qtile
from libqtile.config import Key
from libqtile.lazy import lazy

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
    Key([mod, "control"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
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
    # session management
    Key([mod, "control", "shift"], "e", lazy.shutdown(), desc="Logout Qtile"),
    Key(
        [mod, "control", "shift"],
        "l",
        lazy.spawn("betterlockscreen -l"),
        desc="Lock screen",
    ),
    Key([mod, "control", "shift"], "r", lazy.spawn("systemctl reboot"), desc="Reboot"),
    Key(
        [mod, "control", "shift"],
        "s",
        lazy.spawn("systemctl poweroff"),
        desc="Shutdown",
    ),
    # volume
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("amixer sset Master 5%-"),
        desc="Decrease volume",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("amixer sset Master 5%+"),
        desc="Increase volume",
    ),
    Key([], "XF86AudioMute", lazy.spawn("amixer sset Master 1+ toggle"), desc="Mute"),
    # volume v2
    Key(
        [mod, alt],
        "j",
        lazy.spawn("amixer sset Master 5%-"),
        desc="Decrease volume",
    ),
    Key(
        [mod, alt],
        "k",
        lazy.spawn("amixer sset Master 5%+"),
        desc="Increase volume",
    ),
    Key([mod, alt], "m", lazy.spawn("amixer sset Master 1+ toggle"), desc="Mute"),
    # Brightness
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl -c backlight set 2%+"),
        desc="Increase brightness",
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl -c backlight set 2%-"),
        desc="Decrease brightness",
    ),
    # mouseless pointer
    Key([mod], "d", lazy.spawn("warpd --hint"), desc="Launch pointer hint mode"),
    Key(
        [mod, "shift"],
        "d",
        lazy.spawn("warpd --hint2"),
        desc="Launch pointer hint 2step mode",
    ),
    Key([mod], "c", lazy.spawn("warpd --normal"), desc="Launch pointer normal mode"),
    Key([mod], "g", lazy.spawn("warpd --grid"), desc="Launch pointer grid mode"),
    Key([mod], "s", lazy.spawn("warpd --screen"), desc="Launch pointer screen mode"),
    # Launchers
    Key([alt], "k", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [alt], "r", lazy.spawn("rofi -i -modi drun,run -show drun"), desc="Launch rofi"
    ),
    Key([alt], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key(
        [mod, alt], "Return", lazy.spawn("gnome-terminal"), desc="Launch gnome terminal"
    ),
    Key([alt], "s", lazy.spawn("gnome-control-center"), desc="Launch gnome settings"),
    Key([alt], "v", lazy.spawn("ghostty -e /opt/nvim/bin/nvim"), desc="Launch nvim"),
    Key([alt], "a", lazy.spawn("ghostty -e calcurse"), desc="Launch calendar"),
    Key([alt], "n", lazy.spawn("jupyter-lab"), desc="Launch jupyter lab"),
    Key([alt], "f", lazy.spawn("ghostty -e ranger"), desc="Launch range file manager"),
    Key(
        [alt],
        "w",
        lazy.spawn("libreoffice25.2 --writer"),
        desc="Launch libreoffice writer",
    ),
    Key([alt], "b", lazy.spawn("librewolf"), desc="Launch librewolf"),
    Key(
        [alt],
        "q",
        lazy.spawn("qutebrowser --qt-arg class web --qt-arg name web"),
        desc="Launch qutebrowser",
    ),
    Key(
        [alt],
        "y",
        lazy.spawn(
            "qutebrowser --basedir /home/urtzi/.config/quteyoutube --qt-arg class youtube --qt-arg name youtube"
        ),
        desc="Launch qutebrowser for youtube",
    ),
    Key([alt], "z", lazy.spawn("zotero"), desc="Launch zotero"),
    Key([alt], "i", lazy.spawn("inkscape"), desc="Launch inkscape"),
    Key([alt], "g", lazy.spawn("gimp"), desc="Launch gimp"),
    Key([alt], "o", lazy.spawn("zoom"), desc="Launch zoom"),
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

# Add help key
launcher = "rofi -i -show run -matching fuzzy"
keys_str = ""
for key in keys:
    modifs = key.modifiers
    modifs = [m.replace("mod1", "alt") for m in modifs]
    modifs = [m.replace("mod4", "super") for m in modifs]
    keypress = modifs + [key.key]
    keypress_str = "-".join(keypress)
    keys_str += keypress_str + ": " + key.desc + "\n"

help_desc = "Show qtile keys in rofi"
help_mod = "super-control"
help_key = "y"
keys_str += f"{help_mod}-{help_key}: {help_desc}"


def get_launcher_command(s, prompt, launcher):
    return {
        "shell": True,
        "cmd": f"echo '{s}' | {launcher} -dmenu -p '{prompt}'",
    }


keys.append(
    Key(
        [mod, "control"],
        help_key,
        lazy.spawn(**get_launcher_command(keys_str, "Qtile keys", launcher)),
        desc="bla",
    )
)
