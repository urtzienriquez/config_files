from libqtile.config import Screen
from barc import top_bar

screens = [
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=top_bar(margey=1),
    ),
    Screen(
        wallpaper="~/Pictures/tux.png",
        wallpaper_mode="fill",
        top=top_bar(fontsize=14, barheight=24),
    ),
]
