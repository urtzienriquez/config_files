local wezterm = require("wezterm")
local mod = {}

-- Export configs so workspace_switcher can read them
mod.tab_bar_configs = {
  nightfox = {
    background = "#131a24",
    inactive_tab = { bg_color = "#131a24", fg_color = "#aeafb0" },
    active_tab = { bg_color = "#192330", fg_color = "#dbc074" },
  },
  dayfox = {
    background = "#d0d0d0",
    inactive_tab = { bg_color = "#d0d0d0", fg_color = "#837a72" },
    active_tab = { bg_color = "#f6f2ee", fg_color = "#352c24" },
  },
}

-- Initialize global state
_G.current_theme = "nightfox"

local function toggle_colors(window)
  local overrides = window:get_config_overrides() or {}
  local new_scheme = (overrides.color_scheme == "dayfox") and "nightfox" or "dayfox"

  -- Update global state
  _G.current_theme = new_scheme

  -- Apply color scheme AND tab bar colors
  overrides.color_scheme = new_scheme
  overrides.colors = { tab_bar = mod.tab_bar_configs[new_scheme] }

  window:set_config_overrides(overrides)
end

function mod.with_options(config)
  config.color_scheme_dirs = { wezterm.config_dir .. "/colors" }
  local appearance = wezterm.gui.get_appearance()
  local initial_scheme = appearance:find("Light") and "dayfox" or "nightfox"

  _G.current_theme = initial_scheme
  config.color_scheme = initial_scheme
  config.colors = { tab_bar = mod.tab_bar_configs[initial_scheme] }

  wezterm.on("toggle-colorscheme", toggle_colors)
end

return mod
