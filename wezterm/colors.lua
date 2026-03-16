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

wezterm.on("toggle-colorscheme", function(window, pane)
  local overrides = window:get_config_overrides() or {}

  local is_dark = (overrides.color_scheme ~= "dayfox")
  local new_scheme = is_dark and "dayfox" or "nightfox"
  local new_gnome_setting = is_dark and "prefer-light" or "prefer-dark"

  wezterm.run_child_process({
    "gsettings",
    "set",
    "org.gnome.desktop.interface",
    "color-scheme",
    new_gnome_setting,
  })

  _G.current_theme = new_scheme
  overrides.color_scheme = new_scheme
  overrides.colors = { tab_bar = mod.tab_bar_configs[new_scheme] }

  window:set_config_overrides(overrides)
end)

-- Helper to pick theme based on system appearance
local function get_theme_name()
  if wezterm.gui and wezterm.gui.get_appearance():find("Dark") then
    return "nightfox"
  end
  return "dayfox"
end

-- Update the colorscheme and tab bar colors
local function apply_theme(window, scheme)
  local overrides = window:get_config_overrides() or {}

  _G.current_theme = scheme

  overrides.color_scheme = scheme
  overrides.colors = { tab_bar = mod.tab_bar_configs[scheme] }

  window:set_config_overrides(overrides)
end

-- Listen for system changes
wezterm.on("window-config-reloaded", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local new_scheme = get_theme_name()

  if overrides.color_scheme ~= new_scheme then
    apply_theme(window, new_scheme)
  end
end)

function mod.with_options(config)
  -- Set initial theme based on system on startup
  config.color_scheme = get_theme_name()
  config.colors = { tab_bar = mod.tab_bar_configs[config.color_scheme] }
end

return mod
