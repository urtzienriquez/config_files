from libqtile.config import Group, Match

groups = []
group_names = [str(i) for i in range(1, 9)]
group_labels = [
    "ws1",
    "ws2",
    "ws3",
    "web",
    "yt",
    "zot",
    "graph",
    "zoom",
]
group_layouts = [
    "columns",
    "columns",
    "columns",
    "max",
    "max",
    "treetab",
    "max",
    "columns",
]
group_matches = [
    [],
    [],
    [],
    ["web", "librewolf"],
    ["youtube"],
    ["Zotero"],
    ["Inkscape", "Gimp"],
    ["zoom"],
]
group_exclusive = [False, False, False, False, False, False, False, True]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
            matches=([Match(wm_class=group_matches[i])]),
            exclusive=group_exclusive[i],
        )
    )
