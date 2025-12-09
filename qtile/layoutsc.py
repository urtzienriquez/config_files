from libqtile.config import Match
from libqtile import layout


def init_layout_theme():
    return {
        "border_focus": "#ff966c",
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
        inactive_bg="#458587",
    ),
]


floating_layout = layout.Floating(
    border_focus="#589ed7",
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="gnome-control-center"),  # gnome-control-center
        Match(wm_class="calendar"),  # calendar
        Match(wm_class="fzf-nova"),  # fzf-nova
        Match(wm_class="ranger"),  # ranger
        Match(wm_class="qtile-keys"),  # qtile keys helper
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        # Zotero LibreOffice citation popup - match by window role "Toplevel"
        Match(wm_class="Zotero", role="Toplevel"),
    ],
)
