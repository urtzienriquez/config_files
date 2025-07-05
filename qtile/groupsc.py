from libqtile.config import Group, Match

groups = []
group_names = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
]
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
    "columns",
    "columns",
    "columns",
    "columns",
]
group_matches = [
    [],
    [],
    [],
    [],
    ["web"],
    ["youtube"],
    ["Zotero"],
    ["Inkscape", "Gimp"],
    ["zoom"],
]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
            matches=([Match(wm_class=group_matches[i])]),
        )
    )
