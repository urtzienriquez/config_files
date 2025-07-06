from libqtile.config import Match
from libqtile import layout


def init_layout_theme():
    return {
        "border_focus": "#d79922",
        "border_normal": "#000000",
        "border_width": 2,
        "margin": 0,
    }


layout_theme = init_layout_theme()

layouts = [
    layout.Columns(**layout_theme, insert_position=1),
    layout.Max(**layout_theme),
    layout.TreeTab(
        **layout_theme,
        active_bg="#d79922",
        active_fg="#000000",
        inactive_bg="458587",
    ),
    # layout.Zoomy(**layout_theme),
    # layout.MonadTall(**layout_theme),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(**layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.MonadWide(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Tile(**layout_theme),
    # layout.VerticalTile(**layout_theme),
]


floating_layout = layout.Floating(
    # **layout_theme,
    border_focus="458587",
    border_width=2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="gnome-control-center"),  # gnome-control-center
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
)
