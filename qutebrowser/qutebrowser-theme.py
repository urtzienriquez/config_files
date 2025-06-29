#####################################################################
## THEME

# background color for categories
c.colors.completion.category.bg = "#202020"
c.colors.completion.category.border.top = "#202020"
c.colors.completion.category.border.bottom = "#202020"
# Background color of the completion widget
c.colors.completion.odd.bg = "#000000"
c.colors.completion.even.bg = "#000000"
# match color
c.colors.completion.match.fg = "#D79922"
c.colors.completion.item.selected.match.fg = "#000000"
# Background color of the selected completion item.
c.colors.completion.item.selected.bg = "#D79922"
c.colors.completion.item.selected.border.top = "#D79922"
c.colors.completion.item.selected.border.bottom = "#D79922"
# color for prompts
c.colors.prompts.bg = "#000000"

# use dark mode by default if the webpage "offers" it
config.set("colors.webpage.preferred_color_scheme", "dark")

# disable scrollbar
config.set("scrolling.bar", "never")
config.set("completion.scrollbar.width", 0)

# vertical tabs
config.set("tabs.position", "top")

# hidden tabs and statusbar by default
config.set("statusbar.show", "in-mode")
config.set("tabs.show", "switching")
