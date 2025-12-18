from libqtile.config import Screen
from libqtile import bar, widget
import subprocess

colors = {
    "bg": "#1A1B26",
    "bg_alt": "#373B41",
    "primary": "#D79922",
    "secondary": "#8ABEB7",
    "alert": "#A54242",
    "disabled": "#707880",
    "occupied": "#458587",
    "urgent": "#bd2c40",
}

FONT = "JetBrainsMonoNLNerdFont"


def make_group_box(fontsize, margey):
    """Create a new GroupBox widget instance"""
    return widget.GroupBox(
        font=FONT,
        fontsize=fontsize,
        padding=6,
        margin_y=margey,
        margin_x=0,
        borderwidth=0,
        active=colors["primary"],
        inactive=colors["disabled"],
        highlight_method="block",
        # Single monitor: only this is used
        this_current_screen_border=colors["primary"],
        # Dual monitor: these are also used
        this_screen_border=colors["occupied"],
        other_current_screen_border=colors["bg_alt"],
        other_screen_border=colors["occupied"],
        urgent_border=colors["urgent"],
        urgent_text=colors["urgent"],
        block_highlight_text_color=colors["bg"],
        background=colors["bg"],
        rounded=False,
    )


def main_bar(fontsize=18, barheight=26, margey=3):
    return bar.Bar(
        [
            # LEFT
            # Workspaces
            make_group_box(fontsize, margey),
            widget.Spacer(),
            # RIGHT
            # Chord (mode)
            widget.Chord(
                foreground="#989cff",
                font=FONT,
                fontsize=fontsize,
            ),
            widget.TextBox(  # add an space
                text=" ",
                fontsize=fontsize,
                foreground=colors["bg"],
                background=colors["bg"],
            ),
            # Layout indicator
            widget.CurrentLayoutIcon(
                scale=0.6,
                foreground="#989cff",
            ),
            widget.TextBox(  # add an space
                text=" ",
                fontsize=fontsize,
                foreground=colors["bg"],
                background=colors["bg"],
            ),
            # CPU
            widget.CPU(
                format=" {load_percent}% ",
                foreground=colors["primary"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Memory
            widget.Memory(
                measure_mem="G",
                format=" {MemUsed:.1f}G/{Available:.1f}G ",
                foreground=colors["primary"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Filesystem
            widget.GenPollText(
                func=lambda: " "
                + subprocess.check_output(["df", "-h", "--output=pcent", "/"])
                .decode()
                .splitlines()[1]
                .strip()
                + " ",
                update_interval=60,
                foreground=colors["primary"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Backlight
            widget.Backlight(
                backlight_name="intel_backlight",
                format="󰃟 {percent:2.0%} ",
                foreground=colors["primary"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Audio
            widget.Volume(
                fmt=" {} ",
                foreground=colors["primary"],
                font=FONT,
                fontsize=fontsize,
            ),
            # WiFi
            widget.Wlan(
                format="󰖩 ",
                disconnected_message="󰤮 ",
                interface="wlo1",
                font=FONT,
                fontsize=fontsize,
            ),
            # Ethernet
            widget.GenPollText(
                func=lambda: (
                    "󰌗 "
                    if subprocess.run(
                        ["cat", "/sys/class/net/enp4s0/operstate"],
                        capture_output=True,
                        text=True,
                    ).stdout.strip()
                    == "up"
                    else " "
                ),
                update_interval=5,
                font=FONT,
                fontsize=fontsize,
            ),
            # Battery
            widget.Battery(
                format="{char}{percent:2.0%} ",
                charge_char="󰂄",
                discharge_char="󱐤",
                empty_char="󰂎",
                full_char="󰁹",
                full_short_text="󰁹",
                low_foreground=colors["alert"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Clock
            widget.Clock(
                format="%H:%M",
                font=FONT,
                fontsize=fontsize,
                foreground="#989cff",
            ),
        ],
        barheight,
        background=colors["bg"],
        opacity=1.0,
    )


screens = [
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=main_bar(margey=1),
    ),
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=main_bar(fontsize=14, barheight=24),
    ),
]
