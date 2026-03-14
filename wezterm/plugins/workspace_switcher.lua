local wezterm = require("wezterm")
local util = require("util")
local colors = require("colors") -- Ensure colors.lua is importable
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local mod = {}

function mod.with_options(config)
  workspace_switcher.apply_to_config(config)

  workspace_switcher.workspace_formatter = function(label)
    -- Default to nightfox if global theme isn't set
    local theme = _G.current_theme or "nightfox"
    local active_colors = colors.tab_bar_configs[theme].active_tab

    return wezterm.format({
      { Attribute = { Italic = true } },
      { Foreground = { Color = active_colors.fg_color } },
      { Background = { Color = active_colors.bg_color } },
      { Text = " 󱂬: " .. label .. " " },
    })
  end

  -- Create the new key binding
  local workspace_key = {
    key = "g",
    mods = "LEADER",
    action = workspace_switcher.switch_workspace({
      spawn = { domain = { DomainName = "unix" } },
    }),
  }

  -- Use your util.concat to ensure the key is correctly added to config.keys
  config.keys = util.concat(config.keys or {}, { workspace_key })
end

return mod
