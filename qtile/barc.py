from libqtile import bar, widget
import subprocess

colors = {
    "bg": "#1A1B26",
    "primary": "#D79922",
    "secondary": "#458587",
    "disabled": "#707880",
    "alert": "#A54242",
    "urgent": "#bd2c40",
    "text": "#989cff",
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
        rounded=False,
        highlight_method="block",
        background=colors["bg"],
        active=colors["primary"],
        inactive=colors["disabled"],
        urgent_border=colors["urgent"],
        urgent_text=colors["urgent"],
        block_highlight_text_color=colors["bg"],
        # focused monitor
        this_current_screen_border=colors["primary"],
        other_screen_border=colors["secondary"],
        # unfocused monitor
        this_screen_border=colors["disabled"],
        other_current_screen_border=colors["secondary"],
    )


def top_bar(fontsize=18, barheight=26, margey=3):
    return bar.Bar(
        [
            # LEFT
            # Workspaces
            make_group_box(fontsize, margey),
            widget.Spacer(),
            # RIGHT
            # Chord (mode) (TextBox to add an space)
            widget.Chord(
                foreground=colors["text"],
                font=FONT,
                fontsize=fontsize,
            ),
            widget.TextBox(
                text=" ",
                fontsize=fontsize,
                foreground=colors["bg"],
                background=colors["bg"],
            ),
            # Layout indicator (TextBox to add an space)
            widget.CurrentLayoutIcon(
                scale=0.6,
            ),
            widget.TextBox(
                text=" ",
                fontsize=fontsize,
                foreground=colors["bg"],
                background=colors["bg"],
            ),
            # CPU
            widget.TextBox(
                text="",
                font=FONT,
                fontsize=fontsize,
                foreground=colors["primary"],
                padding = 7,
            ),
            widget.CPU(
                format="{load_percent}% ",
                font=FONT,
                fontsize=fontsize,
            ),
            # Memory
            widget.TextBox(
                text="",
                font=FONT,
                fontsize=fontsize,
                foreground=colors["primary"],
                padding = 7,
            ),
            widget.Memory(
                measure_mem="G",
                format="{MemUsed:.1f}G/{Available:.1f}G ",
                font=FONT,
                fontsize=fontsize,
            ),
            # Filesystem
            widget.TextBox(
                text="",
                font=FONT,
                fontsize=fontsize,
                foreground=colors["primary"],
                padding = 7,
            ),
            widget.GenPollText(
                func=lambda: subprocess.check_output(["df", "-h", "--output=pcent", "/"])
                .decode()
                .splitlines()[1]
                .strip()
                + " ",
                update_interval=60,
                font=FONT,
                fontsize=fontsize,
            ),
            # Backlight
            widget.Backlight(
                backlight_name="intel_backlight",
                format="󰃟 {percent:2.0%} ",
                foreground=colors["text"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Audio
            widget.Volume(
                fmt=" {} ",
                foreground=colors["text"],
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
                charge_char="󰂄 ",
                discharge_char="󱐤 ",
                empty_char="󰂎 ",
                full_char="󰁹 ",
                full_short_text="󰁹 ",
                low_foreground=colors["alert"],
                font=FONT,
                fontsize=fontsize,
            ),
            # Clock
            widget.Clock(
                format="%H:%M",
                font=FONT,
                fontsize=fontsize,
                foreground=colors["text"],
            ),
        ],
        barheight,
        background=colors["bg"],
        opacity=1.0,
    )
