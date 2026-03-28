local wezterm = require("wezterm")
local util = require("util")
local colors = require("colors")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local mod = {}

function mod.with_options(config)
  workspace_switcher.apply_to_config(config)

  workspace_switcher.workspace_formatter = function(label)
    local theme_name = _G.current_theme or "nightfox"
    local theme = colors.themes[theme_name]
    local active_colors = theme.tab_bar.active_tab

    return wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { Color = active_colors.fg_color } },
      { Background = { Color = active_colors.bg_color } },
      { Text = "󱂬 : " .. label .. " " },
    })
  end

  config.keys = util.concat(config.keys or {}, {
    {
      key = "g",
      mods = "LEADER",
      action = workspace_switcher.switch_workspace({
        spawn = { domain = { DomainName = "unix" } },
      }),
    },
  })
end

return mod
