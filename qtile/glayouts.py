from libqtile import layout
from libqtile.config import Group, Match

groups = [
    Group(
        name="work1",
    ),
    Group(
        name="work2",
    ),
    Group(
        name="work3",
    ),
    Group(
        name="work4",
    ),
    Group(
        name="web",
        matches=[Match(wm_class=["web"])],
        layout="max",
    ),
    Group(
        name="youtube",
        matches=[Match(wm_class=["youtube"])],
        layout="max",
    ),
    Group(
        name="zotero",
        matches=[Match(wm_class=["Zotero"])],
    ),
    Group(
        name="graphics",
        matches=[Match(wm_class=["Inkscape", "Gimp"])],
    ),
    Group(
        name="zoom",
        matches=[Match(wm_class=["zoom"])],
    ),
]


def init_layout_theme():
    return {
        "border_focus": "#d79922",
        "border_normal": "#000000",
        "border_width": 2,
        "margin": 0,
    }


layout_theme = init_layout_theme()

layouts = [
    # layout.MonadTall(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]


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
