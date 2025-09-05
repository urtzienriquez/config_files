from libqtile import qtile
from libqtile.config import Key, KeyChord
from libqtile.lazy import lazy

from groupsc import groups

mod = "mod4"
alt = "mod1"
terminal = "alacritty"


def swap_screens():
    @lazy.function
    def __inner(qtile):
        if len(qtile.screens) < 2:
            return
        
        # Get current screen index
        current_screen_index = qtile.screens.index(qtile.current_screen)
        
        # Calculate other screen index (works for 2+ screens)
        other_screen_index = (current_screen_index + 1) % len(qtile.screens)
        
        # Get the groups from both screens
        current_group = qtile.current_screen.group
        other_group = qtile.screens[other_screen_index].group
        
        # Swap the groups without changing focus
        qtile.screens[other_screen_index].set_group(current_group)
        qtile.current_screen.set_group(other_group)

    return __inner

keys = [
    Key(
        [mod],
        "space",
        lazy.next_screen(),
        desc="Next monitor",
    ),
    Key(
        [mod, "control"],
        "space",
        swap_screens(),
        desc="Swap screens, but keep focus",
    ),
    Key(
        [mod, "control", "shift"],
        "space",
        swap_screens(),
        lazy.next_screen(),
        desc="Swap screens and change focused screen",
    ),
    Key(
        [mod],
        "h",
        lazy.layout.left(),
        desc="Move focus to left",
    ),
    Key(
        [mod],
        "l",
        lazy.layout.right(),
        desc="Move focus to right",
    ),
    Key(
        [mod],
        "j",
        lazy.layout.down(),
        desc="Move focus down",
    ),
    Key(
        [mod],
        "k",
        lazy.layout.up(),
        desc="Move focus up",
    ),
    Key(
        [mod],
        "w",
        lazy.layout.next(),
        desc="Move window focus to other window",
    ),
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        desc="Move window to the left",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        desc="Move window down",
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_up(),
        desc="Move window up",
    ),
    Key(
        [mod, "control"],
        "h",
        lazy.layout.grow_left(),
        desc="Grow window to the left",
    ),
    Key(
        [mod, "control"],
        "l",
        lazy.layout.grow_right(),
        desc="Grow window to the right",
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.grow_down(),
        desc="Grow window down",
    ),
    Key(
        [mod, "control"],
        "k",
        lazy.layout.grow_up(),
        desc="Grow window up",
    ),
    Key(
        [mod, "control"],
        "n",
        lazy.layout.normalize(),
        desc="Reset all window sizes",
    ),
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key(
        [mod],
        "Tab",
        lazy.next_layout(),
        desc="Toggle between layouts",
    ),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "n",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    Key(
        [mod, "control"],
        "r",
        lazy.reload_config(),
        desc="Reload the config",
    ),
    # session management
    Key(
        [mod, "control", "shift"],
        "x",
        lazy.spawn(
            'bash -c "alacritty --class=fzf-nova -e $HOME/config_files/fzf-nova/_session,--.manage.session"'
        ),
        desc="Manage Qtile session",
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
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("amixer sset Master 1+ toggle"),
        desc="Mute",
    ),
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
    Key(
        [mod, alt],
        "m",
        lazy.spawn("amixer sset Master 1+ toggle"),
        desc="Mute",
    ),
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
    # # mouseless pointer
    # Key(
    #     [mod],
    #     "d",
    #     lazy.spawn("warpd --hint"),
    #     desc="Launch pointer hint mode",
    # ),
    # Key(
    #     [mod, "shift"],
    #     "d",
    #     lazy.spawn("warpd --hint2"),
    #     desc="Launch pointer hint 2step mode",
    # ),
    # Key(
    #     [mod],
    #     "c",
    #     lazy.spawn("warpd --normal"),
    #     desc="Launch pointer normal mode",
    # ),
    # Key(
    #     [mod],
    #     "g",
    #     lazy.spawn("warpd --grid"),
    #     desc="Launch pointer grid mode",
    # ),
    # Key(
    #     [mod],
    #     "s",
    #     lazy.spawn("warpd --screen"),
    #     desc="Launch pointer screen mode",
    # ),
    # Launchers
    Key(
        [alt],
        "q",
        lazy.window.kill(),
        desc="Kill focused window",
    ),
    Key(
        [alt],
        "f",
        lazy.spawn(
            'bash -c "alacritty --class=fzf-nova -e $HOME/config_files/fzf-nova/fzf-nova"'
        ),
        desc="Launch fzf-nova",
    ),
    Key(
        [alt],
        "s",
        lazy.spawn("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center"),
        desc="Launch terminal",
    ),
    Key(
        [alt],
        "Return",
        lazy.spawn(terminal),
        desc="Launch terminal",
    ),
    Key(
        [mod, alt],
        "Return",
        lazy.spawn("gnome-terminal"),
        desc="Launch gnome terminal",
    ),
    Key(
        [alt],
        "v",
        lazy.spawn("alacritty -e /opt/nvim/bin/nvim"),
        desc="Launch nvim",
    ),
    Key(
        [alt],
        "c",
        lazy.spawn("alacritty --class='calendar' -e calcurse"),
        desc="Launch calendar",
    ),
    Key(
        [alt],
        "n",
        lazy.spawn("jupyter-lab"),
        desc="Launch jupyter lab",
    ),
    Key(
        [alt],
        "r",
        lazy.spawn("alacritty --class='ranger' -e ranger"),
        desc="Launch range file manager",
    ),
    Key(
        [alt],
        "w",
        lazy.spawn("libreoffice --writer"),
        desc="Launch libreoffice writer",
    ),
    Key(
        [alt],
        "b",
        lazy.to_screen(0),
        lazy.group["4"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn("firefox"),
        desc="Launch firefox",
    ),
    Key(
        [alt],
        "j",
        lazy.to_screen(0),
        lazy.group["4"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn("qutebrowser --qt-arg class web --qt-arg name web"),
        desc="Launch qutebrowser",
    ),
    Key(
        [alt],
        "y",
        lazy.to_screen(0),
        lazy.group["4"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn(
            "qutebrowser --basedir /home/urtzi/.config/quteyoutube \
                    --qt-arg class youtube --qt-arg name youtube",
        ),
        desc="Launch qutebrowser for youtube",
    ),
    Key(
        [alt],
        "z",
        lazy.to_screen(0),
        lazy.spawn("zotero"),
        desc="Launch zotero",
    ),
    Key(
        [alt],
        "i",
        lazy.spawn("inkscape"),
        desc="Launch inkscape",
    ),
    Key(
        [alt],
        "g",
        lazy.spawn("gimp"),
        desc="Launch gimp",
    ),
    Key(
        [alt],
        "o",
        lazy.spawn("zoom"),
        desc="Launch zoom",
    ),
    Key(
        [],
        "Print",
        lazy.spawn("gnome-screenshot -i"),
        desc="Launch screenshot with Print key",
    ),
    Key(
        [alt],
        "p",
        lazy.spawn("gnome-screenshot -i"),
        desc="Launch screenshot with keyboard",
    ),
]

# # Add key bindings to switch VTs in Wayland.
# for vt in range(1, 8):
#     keys.append(
#         Key(
#             ["control", "mod1"],
#             f"f{vt}",
#             lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
#             desc=f"Switch to VT{vt}",
#         )
#     )

# key bindings to switch and move between groups
for i in groups:
    keys.extend(
        [
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}: {}".format(i.name, i.label),
            ),
            Key(
                [mod, "control"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Move focused window to group {}: {}".format(i.name, i.label),
            ),
            Key(
                [mod, "control", "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Move focused window and switch to group {}: {}".format(
                    i.name, i.label
                ),
            ),
        ]
    )

# retrieve key information
keys_list = []
for key in keys:
    modifs = key.modifiers
    modifs = [m.replace("mod1", "alt") for m in modifs]
    modifs = [m.replace("mod4", "super") for m in modifs]
    keypress = modifs + [key.key]
    keypress_str = "-".join(keypress)
    keys_list.append(f"{keypress_str}: {key.desc}")

# add helper key
help_desc = "Show qtile keys in alacritty with fzf"
help_mod = "super-alt"
help_key = "f"
keys_list.append(f"{help_mod}-{help_key}: {help_desc}")


def get_launcher_command(key_list):
    # Create the command using here-document to avoid escaping issues
    keys_text = "\n".join(key_list)
    return {
        "shell": True,
        "cmd": f"alacritty --class='qtile-keys' -e bash -c 'cat <<EOF | fzf --reverse --prompt=\"Qtile keys: \"\n{keys_text}\nEOF'",
    }


keys.append(
    Key(
        [mod, alt],
        help_key,
        lazy.spawn(**get_launcher_command(keys_list)),
        desc=help_desc,
    )
)
