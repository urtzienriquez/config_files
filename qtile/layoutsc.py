import re

from libqtile.config import Match
from libqtile import layout, qtile


def _other_zotero(win):
    """Is another Zotero window already managed?"""
    return any(
        w is not win and getattr(w, "get_wm_class", lambda: None)() == ["Zotero"]
        for w in qtile.windows_map.values()
    )


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
        # dialogs (windows with a parent). X11 floats these by itself, but
        # qtile's Wayland backend reports native dialogs as "normal" windows
        Match(func=lambda c: c.is_transient_for() is not None),
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(wm_class="gnome-control-center"),  # gnome-control-center
        Match(wm_class="org.gnome.Settings"),  # gnome-control-center (Wayland)
        Match(title="calendar"),  # calendar
        Match(title="fzf-nova"),  # fzf-nova
        Match(title="yazi"),  # yazi
        Match(title="qeditor"),  # nvim editor in qutebrowser
        Match(wm_class="qtile-keys"),  # qtile keys helper
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        # Zotero LibreOffice citation popup - match by window role "Toplevel"
        Match(wm_class="Zotero", role="Toplevel"),
        # same popup on Wayland (no roles there): match by its title
        Match(wm_class="Zotero", title=re.compile(r"Citation|Quick Format")),
        # Wayland: Zotero's windows have no role and no parent, so float every
        # Zotero window opened while another one (the main window) exists.
        # (X11's WM_CLASS has two entries, so this never matches there)
        Match(func=lambda c: c.get_wm_class() == ["Zotero"] and _other_zotero(c)),
        Match(wm_class="love-11.5"),
        Match(wm_class="gksqt"),
        Match(wm_class="r_x11"),
    ],
)
