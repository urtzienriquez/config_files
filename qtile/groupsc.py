from libqtile.config import Group, Match

groups = []
group_names = [str(i) for i in range(1, 9)]
group_labels = [
    " w1",
    " w2",
    " w3",
    "󰖟 wb",
    " yt",
    "󰰶 zt",
    " gr",
    " zm",
]
group_layouts = [
    "columns",
    "columns",
    "columns",
    "columns",
    "columns",
    "treetab",
    "columns",
    "columns",
]
group_matches = [
    [],
    [],
    [],
    [Match(wm_class="web"), Match(wm_class="firefox-esr")],
    [Match(wm_class="youtube")],
    # Match only main Zotero window by its window role "browser"
    [Match(wm_class="Zotero", role="browser")],
    [Match(wm_class="Inkscape"), Match(wm_class="Gimp")],
    [Match(wm_class="zoom")],
]
group_exclusive = [False, False, False, False, False, False, False, True]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
            matches=group_matches[i],
            exclusive=group_exclusive[i],
        )
    )
