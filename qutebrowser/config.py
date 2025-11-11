# don't load the autoconfig.yaml, but the config.py instead
config.load_autoconfig(False)

# set the theme
config.source("qutebrowser-theme.py")

# set start page
config.source("start-page.py")

# set font size
config.set("fonts.default_size", "11pt")

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

# don't allow to recycle through tabs
config.set("tabs.wrap", False)

# use best match for partial command autocompletion
config.set("completion.use_best_match", True)

# enable notifications
config.set("content.notifications.enabled", True)

# # never use proxy for youtube
# config.set("content.proxy", "system", "*://youtube.com/")

# use ranger as file picker
config.set("fileselect.handler", "external")
config.set(
    "fileselect.single_file.command",
    [
        "ghostty",
        "--x11-instance-name=ranger",
        "--window-width=80",
        "--window-height=25",
        "-e",
        "ranger",
        "--choosefile={}",
    ],
)
config.set(
    "fileselect.multiple_files.command",
    [
        "ghostty",
        "--x11-instance-name=ranger",
        "--window-width=80",
        "--window-height=25",
        "-e",
        "ranger",
        "--choosefiles={}",
    ],
)

# open neovim from qutebrowser
c.editor.command = ["ghostty", "-e", "/opt/nvim/bin/nvim", "-f", "{}"]

# edit url / to edit text control-e in insert mode sends you to the editor
config.bind("eu", "edit-url")

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

# navigate completion in serarch bars (insert mode) with ctrl-j / ctrl-k
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

# spawn video in mpv
# c.aliases["mpv"] = "spawn --userscript view_in_mpv"
config.bind("tv", "spawn --userscript view_in_mpv")
config.bind("gv", "hint links spawn mpv {hint-url}")

# Proxy to use
config.bind("pi", "set content.proxy http://proxy.ivb.cz:3128/")
config.bind("ps", "set content.proxy system")

# download images with hints
config.bind(";p", "hint images download")

# open page/link in firefox
config.bind("pf", "spawn --detach firefox {url}")
config.bind("ph", "hint links spawn --detach firefox {hint-url}")

# switch mapping of F and ;f so that:
# F follows a link to a new active tab
# ;f opens a link in an inactive tab
config.unbind("F")
config.unbind(";f")
config.bind("F", "hint all tab-fg")
config.bind(";f", "hint all tab")

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


c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist-downloads.adblockplus.org/easylistdutch.txt",
    "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
    "https://www.i-dont-care-about-cookies.eu/abp/",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
]
