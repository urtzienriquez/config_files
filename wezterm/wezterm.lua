local wezterm = require("wezterm")

-- basic utilities
local colors = require("colors")
local keys = require("keys")
local ui = require("ui")
local font = require("font")

-- plugins
local smart_splits = require("plugins/smart_splits")
local resurrect = require("plugins/resurrect")
local workspace_switcher = require("plugins/workspace_switcher")

local config = wezterm.config_builder()

-- base configuration
config.default_prog = { "zsh" }
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {}
config.max_fps = 120
config.unix_domains = { { name = "unix" } }
config.default_workspace = "0_default"

-- plugin options
smart_splits.with_options(config)
workspace_switcher.with_options(config)
resurrect.with_options(config)

-- module options
colors.with_options(config)
font.with_options(config)
ui.with_options(config)
keys.with_options(config)

return config
