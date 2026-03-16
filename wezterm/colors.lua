local wezterm = require("wezterm")
local mod = {}

mod.themes = {
  nightfox = {
    tab_bar = {
      background = "#131a24",
      inactive_tab = { bg_color = "#131a24", fg_color = "#aeafb0" },
      active_tab = { bg_color = "#192330", fg_color = "#dbc074" },
    },
    search = {
      active_bg = "#dbc074",
      active_fg = "#000000",
      inactive_bg = "#293e7a",
      inactive_fg = "#ffffff",
      indicator = "#ff00ff",
    },
    status = {
      workspace = "#63cdcf",
      leader = "#dbc074",
      copy = "#f29e74",
    },
  },
  dayfox = {
    tab_bar = {
      background = "#d0d0d0",
      inactive_tab = { bg_color = "#d0d0d0", fg_color = "#837a72" },
      active_tab = { bg_color = "#f6f2ee", fg_color = "#352c24" },
    },
    search = {
      active_bg = "#dbc074",
      active_fg = "#000000",
      inactive_bg = "#ccd0f5",
      inactive_fg = "#000000",
      indicator = "#ff00ff",
    },
    status = {
      workspace = "#333333",
      leader = "#000000",
      copy = "#f29e74",
    },
  },
}

local function get_system_theme()
  if wezterm.gui and wezterm.gui.get_appearance():find("Dark") then
    return "nightfox"
  end
  return "dayfox"
end

_G.current_theme = get_system_theme()

-- Construct the colors table handling the strict type differences
local function make_colors_table(theme_name)
  local theme = mod.themes[theme_name]
  return {
    tab_bar = theme.tab_bar,

    copy_mode_active_highlight_bg = { Color = theme.search.active_bg },
    copy_mode_active_highlight_fg = { Color = theme.search.active_fg },
    copy_mode_inactive_highlight_bg = { Color = theme.search.inactive_bg },
    copy_mode_inactive_highlight_fg = { Color = theme.search.inactive_fg },

    selection_bg = theme.search.active_bg,
    selection_fg = theme.search.active_fg,
    quick_select_label_bg = { Color = theme.status.leader },
    quick_select_label_fg = { Color = theme.tab_bar.background },
  }
end

local function apply_theme(window, scheme)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == scheme then
    return
  end

  _G.current_theme = scheme
  overrides.color_scheme = scheme
  overrides.colors = make_colors_table(scheme)

  window:set_config_overrides(overrides)
end

wezterm.on("toggle-colorscheme", function(window, pane)
  local new_scheme = (_G.current_theme == "nightfox") and "dayfox" or "nightfox"
  local gsettings_val = (new_scheme == "dayfox") and "prefer-light" or "prefer-dark"

  wezterm.run_child_process({ "gsettings", "set", "org.gnome.desktop.interface", "color-scheme", gsettings_val })
  apply_theme(window, new_scheme)
end)

wezterm.on("window-config-reloaded", function(window, pane)
  local sys = get_system_theme()
  if _G.current_theme ~= sys then
    apply_theme(window, sys)
  end
end)

function mod.with_options(config)
  config.color_scheme = _G.current_theme
  config.colors = make_colors_table(_G.current_theme)
end

return mod
