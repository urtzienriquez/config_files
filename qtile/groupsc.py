from libqtile.config import Group, Match

groups = []
group_names = [str(i) for i in range(1, 10)]
group_labels = [
    "work1",
    "work2",
    "work3",
    "work4",
    "web",
    "youtube",
    "zotero",
    "graphics",
    "zoom",
]
group_layouts = [
    "columns",
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
    [],
    ["web", "librewolf"],
    ["youtube"],
    ["Zotero"],
    ["Inkscape", "Gimp"],
    ["zoom"],
]
group_exclusive = [False, False, False, False, True, True, False, False, True]

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
