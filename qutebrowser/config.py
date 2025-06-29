# don't load the autoconfig.yaml, but the config.py instead
config.load_autoconfig(False)

# set the theme
config.source("qutebrowser-theme.py")

# Which cookies to accept.
config.set("content.cookies.accept", "no-3rdparty", "chrome-devtools://*")

# Value to send in the `Accept-Language` header.
config.set("content.headers.accept_language", "", "https://matchmaker.krunker.io/*")

# User agent to send.
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 ({os_info}; rv:136.0) Gecko/20100101 Firefox/139.0",
    "https://accounts.google.com/*",
)

# Load images automatically in web pages.
config.set("content.images", True, "chrome-devtools://*")
config.set("content.images", True, "devtools://*")

# Enable JavaScript.
config.set("content.javascript.enabled", True, "chrome-devtools://*")
config.set("content.javascript.enabled", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome://*/*")
config.set("content.javascript.enabled", True, "qute://*/*")

# Allow locally loaded documents to access remote URLs.
config.set(
    "content.local_content_can_access_remote_urls",
    True,
    "file:///home/urtzi/.local/share/qutebrowser/userscripts/*",
)

# Allow locally loaded documents to access other local URLs.
config.set(
    "content.local_content_can_access_file_urls",
    False,
    "file:///home/urtzi/.local/share/qutebrowser/userscripts/*",
)

# # use lf as file picker
# config.set("fileselect.handler", "external")
# config.set(
#     "fileselect.single_file.command",
#     ["gnome-terminal", "--", "lf-ueberzug", "-selection-path", "{}"],
# )
# config.set(
#     "fileselect.multiple_files.command",
#     ["gnome-terminal", "--", "lf-ueberzug", "-selection-path", "{}"],
# )

# open neovim from qutebrowser
c.editor.command = ["ghostty", "-e", "/opt/nvim/bin/nvim", "-f", "{}"]

# Readline keybinds
config.bind("<Ctrl-0>", "fake-key <Home>", "insert")
config.bind("<Ctrl-4>", "fake-key <End>", "insert")
config.bind("<Ctrl-b>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Ctrl-w>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-d>", "fake-key <Ctrl-Backspace>", "insert")
config.bind("<Ctrl-u>", "fake-key <Shift-Home><Delete>", "insert")
config.bind("<Ctrl-k>", "fake-key <Shift-End><Delete>", "insert")

# navigate completion widget with ctrl-n / ctrl-p
config.bind("<Ctrl-n>", "completion-item-focus next", "command")
config.bind("<Ctrl-p>", "completion-item-focus prev", "command")

# navigate completion in serarch bars (insert mode) with ctrl-n / ctrl-p
config.bind("<Ctrl-n>", "fake-key <Down>", "insert")
config.bind("<Ctrl-p>", "fake-key <Up>", "insert")

# navigate with j and k in passthrough mode (e.g. for protonmail)
config.bind("j", "scroll down", "passthrough")
config.bind("k", "scroll up", "passthrough")

# autofill passwords with pass
# (not possible in prompts, e.g. for proxy, for now)
config.bind("zl", "spawn --userscript qute-pass --dmenu-invocation dmenu")
# config.bind(
#     "<Ctrl-p>", "spawn --userscript qute-pass --dmenu-invocation dmenu", mode="prompt"
# )

# Proxy to use
config.bind("pi", "set content.proxy http://proxy.ivb.cz:3128/")
config.bind("ps", "set content.proxy system")

# download images with hints
config.bind(";p", "hint images download")

# hide/show tabs and status bar
config.bind("xb", "config-cycle statusbar.show always in-mode")
config.bind("xt", "config-cycle tabs.show always switching")
config.bind(
    "xx",
    "config-cycle statusbar.show always in-mode;; config-cycle tabs.show always switching",
)

# toggle light/dark mode
config.bind("td", "config-cycle colors.webpage.darkmode.enabled")

# search engines
config.set(
    "url.searchengines",
    {
        "DEFAULT": "https://duckduckgo.com/?q={}",
        "g": "https://www.google.com/search?q={}",
        "b": "https://search.brave.com/search?q={}",
        "gh": "https://github.com/search?q={}",
        "s": "https://stackoverflow.com/search?q={}",
    },
)
