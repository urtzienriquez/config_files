import subprocess
import os
import json
from pathlib import Path

from libqtile import qtile
from libqtile.config import Key, KeyChord
from libqtile.lazy import lazy

from groupsc import groups

mod = "mod4"
alt = "mod1"
terminal = "ghostty"


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


config_dir = os.path.expanduser("~/.config/qtile/")
local_settings_path = os.path.join(config_dir, "local_settings.json")

HEADPHONES_MAC = "00:00:00:00:00:00"

if os.path.exists(local_settings_path):
    with open(local_settings_path, "r") as f:
        data = json.load(f)
        HEADPHONES_MAC = data.get("headphones_mac", HEADPHONES_MAC)


def toggle_headphones(qtile):
    mac = HEADPHONES_MAC
    if mac == "00:00:00:00:00:00":
        subprocess.run(
            "notify-send 'Error' 'Headphones MAC not configured'", shell=True
        )
        return

    check_cmd = f"bluetoothctl info {mac} | grep 'Connected: yes'"
    connected = subprocess.run(check_cmd, shell=True, capture_output=True)

    if connected.returncode == 0:
        subprocess.run(f"bluetoothctl disconnect {mac}", shell=True)
        subprocess.run(
            f"notify-send 'Bluetooth' 'Monitor III Disconnected'", shell=True
        )
    else:
        subprocess.run(f"bluetoothctl connect {mac}", shell=True)
        subprocess.run(
            f"notify-send 'Bluetooth' 'Connecting to Monitor III...'", shell=True
        )


FZF_CONFIG = Path.home() / ".config/zsh/.fzf_config"


def update_fzf_config(is_dark: bool):
    FZF_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    base = """--height 85%
--layout=reverse
--scrollbar='█'
--bind 'ctrl-v:toggle-preview'
--bind 'ctrl-u:preview-up,ctrl-d:preview-down'
--bind 'ctrl-r:first,ctrl-e:last'
"""
    color = "--color=dark,pointer:#fce094,gutter:#14161b" if is_dark else "--color=light,pointer:#fce094,gutter:#e0e2ea"
    FZF_CONFIG.write_text(f"{color}\n{base}")


def toggle_colorscheme(qtile):
    # Get current GNOME color scheme
    current_scheme = (
        subprocess.check_output(
            ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        )
        .decode("utf-8")
        .strip()
        .replace("'", "")
    )

    is_current_dark = current_scheme == "prefer-dark"
    new_scheme = "prefer-light" if is_current_dark else "prefer-dark"
    is_dark = not is_current_dark  # final state after toggle

    notification = "Dark Mode" if is_dark else "Light Mode"

    # Apply GNOME theme
    subprocess.run(
        [
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "color-scheme",
            new_scheme,
        ]
    )

    # Notify success
    subprocess.run(["notify-send", "Theme Toggled", f"Switched to {notification}"])

    # fzf update
    try:
        update_fzf_config(is_dark)
    except Exception as e:
        subprocess.run(["notify-send", "FZF Theme Error", str(e)])


launcher_keys = [
    Key(
        [],
        "f",
        lazy.spawn("ghostty --x11-instance-name='fzf-nova' \
                    -e bash -c 'source ~/.bashrc &>/dev/null \
                    && $HOME/config_files/fzf-nova/fzf-nova'"),
        desc="Launch fzf-nova",
    ),
    Key(
        [],
        "s",
        lazy.spawn("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center"),
        desc="Launch gnome control center",
    ),
    Key(
        [],
        "Return",
        lazy.spawn(terminal),
        desc="Launch terminal",
    ),
    Key(
        [],
        "q",
        lazy.spawn("gnome-terminal"),
        desc="Launch gnome terminal",
    ),
    Key(
        [],
        "e",
        lazy.spawn("emacs"),
        desc="Launch terminal",
    ),
    Key(
        [],
        "c",
        lazy.spawn(
            "ghostty --x11-instance-name='calendar' --window-height=30 --window-width=120 -e calcurse"
        ),
        desc="Launch calendar",
    ),
    Key(
        [],
        "n",
        lazy.spawn("jupyter-lab"),
        desc="Launch jupyter lab",
    ),
    Key(
        [],
        "y",
        lazy.spawn(
            "ghostty --x11-instance-name='yazi' --window-height=30 --window-width=120 -e yazi"
        ),
        desc="Launch yazi file manager",
    ),
    Key(
        [],
        "w",
        lazy.spawn("libreoffice --writer"),
        desc="Launch libreoffice writer",
    ),
    Key(
        [],
        "b",
        lazy.to_screen(0),
        lazy.group["4"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn("librewolf"),
        desc="Launch librewolf",
    ),
    Key(
        [],
        "j",
        lazy.to_screen(0),
        lazy.group["4"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn("qutebrowser --qt-arg class web --qt-arg name web"),
        desc="Launch qutebrowser",
    ),
    Key(
        [],
        "t",
        lazy.to_screen(0),
        lazy.group["5"].toscreen(0),  # Show web workspace on laptop screen (screen 0)
        lazy.spawn(
            "qutebrowser --basedir /home/urtzi/.config/quteyoutube \
                    --qt-arg class youtube --qt-arg name youtube",
        ),
        desc="Launch qutebrowser for youtube",
    ),
    Key(
        [],
        "z",
        lazy.to_screen(0),
        lazy.spawn("zotero"),
        desc="Launch zotero",
    ),
    Key(
        [],
        "i",
        lazy.spawn("inkscape"),
        desc="Launch inkscape",
    ),
    Key(
        [],
        "g",
        lazy.spawn("gimp"),
        desc="Launch gimp",
    ),
    Key(
        [],
        "o",
        lazy.spawn("zoom"),
        desc="Launch zoom",
    ),
    Key(
        [],
        "p",
        lazy.spawn("gnome-screenshot -i"),
        desc="Launch screenshot with keyboard",
    ),
]

keys = [
    Key(
        [mod],
        "b",
        lazy.function(toggle_colorscheme),
        desc="Toggle between Dark (Nightfox) and Light (Dayfox) themes",
    ),
    Key(
        [mod, alt],
        "h",
        lazy.spawn(
            f'bash -c \'if bluetoothctl info {HEADPHONES_MAC} | grep -q "Connected: yes"; '
            f'then bluetoothctl disconnect {HEADPHONES_MAC} && notify-send "Bluetooth" "Disconnected"; '
            f'else bluetoothctl connect {HEADPHONES_MAC} && notify-send "Bluetooth" "Connecting..."; fi\''
        ),
        desc="Toggle Marshall Headphones",
    ),
    Key(
        [mod, "control"],
        "h",
        lazy.function(toggle_headphones),
        desc="Toggle Marshall Headphones",
    ),
    Key(
        [mod, "control"],
        "r",
        lazy.reload_config(),
        desc="Reload the config",
    ),
    Key(
        [mod],
        "i",
        lazy.spawn("togglekbd"),
        desc="Toggle keyboard input",
    ),
    # session management
    Key(
        [mod, "control", "shift"],
        "x",
        lazy.spawn("ghostty --x11-instance-name='fzf-nova' \
                    -e bash -c 'source ~/.bashrc &>/dev/null \
                    && $HOME/config_files/fzf-nova/_session,--.manage.session'"),
        desc="Manage Qtile session",
    ),
    # monitors
    Key(
        [mod],
        "m",
        lazy.next_screen(),
        desc="Next monitor",
    ),
    Key(
        [mod, "control"],
        "m",
        swap_screens(),
        desc="Swap screens, but keep focus",
    ),
    Key(
        [mod, "control", "shift"],
        "m",
        swap_screens(),
        lazy.next_screen(),
        desc="Swap screens and change focused screen",
    ),
    # windows
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
        lazy.group.next_window(),
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
        [mod],
        "q",
        lazy.window.kill(),
        desc="Kill focused window",
    ),
    Key(
        [],
        "Print",
        lazy.spawn("gnome-screenshot -i"),
        desc="Launch screenshot with Print key",
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
    # Brightness
    Key(
        [],
        "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl -c backlight set 5%+"),
        desc="Increase brightness",
    ),
    Key(
        [],
        "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl -c backlight set 5%-"),
        desc="Decrease brightness",
    ),
    # volume
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
    # brightness
    Key(
        [mod, alt],
        "i",
        lazy.spawn("brightnessctl -c backlight set 5%+"),
        desc="Increase brightness",
    ),
    Key(
        [mod, alt],
        "u",
        lazy.spawn("brightnessctl -c backlight set 5%-"),
        desc="Decrease brightness",
    ),
    # Quick launcher (auto-closes after one app)
    KeyChord(
        [mod],
        "Space",
        launcher_keys,
        name="launcher",
    ),
    # Launcher with mode (stays open for multiple launches)
    KeyChord(
        [mod, "control"],
        "Space",
        launcher_keys,
        mode=True,
        name="multi-launcher",
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
