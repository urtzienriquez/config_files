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
FONT_SIZE = 16
BAR_HEIGHT = 26


def make_group_box():
    """Create a new GroupBox widget instance"""
    return widget.GroupBox(
        font=FONT,
        fontsize=FONT_SIZE,
        padding=6,
        margin_y=3,
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


def main_bar():
    return bar.Bar(
        [
            # LEFT — Workspaces
            make_group_box(),
            widget.Spacer(),
            widget.Chord(
                foreground="#989cff",
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            # Layout indicator
            widget.CurrentLayoutIcon(
                scale=0.6,
                foreground="#989cff",
            ),
            widget.Sep(linewidth=1, foreground=colors["disabled"]),
            # CPU
            widget.CPU(
                format=" {load_percent}%",
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Memory
            widget.Memory(
                measure_mem="G",
                format=" {MemUsed:.1f}G/{MemFree:.1f}G",
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Filesystem
            widget.GenPollText(
                func=lambda: " "
                + subprocess.check_output(["df", "-h", "--output=pcent", "/"])
                .decode()
                .splitlines()[1]
                .strip(),
                update_interval=60,
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Backlight
            widget.Backlight(
                backlight_name="intel_backlight",
                format="󰃟 {percent:2.0%}",
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Audio
            widget.Volume(
                fmt=" {}",
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # WiFi & Ethernet
            widget.Wlan(
                format="󰖩",
                disconnected_message="󰤮",
                interface="wlo1",
                ethernet_interface="enp4s0",
                ethernet_message_format="󰌗 eth",
                use_ethernet=True,
                foreground=colors["primary"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Battery
            widget.Battery(
                format="{char}{percent:2.0%}",
                charge_char="󰂄",
                discharge_char="󱐤",
                empty_char="󰂎",
                full_char="󰁹",
                full_short_text="󰁹",
                foreground=colors["primary"],
                low_foreground=colors["alert"],
                font=FONT,
                fontsize=FONT_SIZE,
            ),
            widget.Sep(),
            # Clock
            widget.Clock(
                format="%H:%M",
                font=FONT,
                fontsize=FONT_SIZE,
            ),
        ],
        BAR_HEIGHT,
        background=colors["bg"],
        opacity=1.0,
    )


screens = [
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=main_bar(),
    ),
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=main_bar(),
    ),
]
