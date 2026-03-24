local wezterm = require("wezterm")
local colors = require("colors")

local mod = {}

wezterm.on("update-status", function(window, pane)
  local theme_name = _G.current_theme or "nightfox"
  local theme = colors.themes[theme_name]

  local status_table = {}
  local workspace = window:active_workspace()

  -- Leader indicator
  if window:leader_is_active() then
    table.insert(status_table, { Foreground = { Color = theme.status.leader } })
    table.insert(status_table, { Text = " 󱐋 " })
  end

  -- Search/Copy mode indicators
  local key_table = window:active_key_table()
  if key_table == "copy_mode" then
    table.insert(status_table, { Foreground = { Color = theme.status.copy } })
    table.insert(status_table, { Text = " 󰆏 " })
  elseif key_table == "search_mode" then
    table.insert(status_table, { Foreground = { Color = theme.search.indicator } })
    table.insert(status_table, { Text = "  " })
  end

  -- Workspace name
  table.insert(status_table, { Foreground = { Color = theme.status.workspace } })
  table.insert(status_table, { Text = " " .. workspace .. " " })

  window:set_right_status(wezterm.format(status_table))
end)

function mod.with_options(config)
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.switch_to_last_active_tab_when_closing_tab = true
  config.show_tabs_in_tab_bar = true
  config.tab_max_width = 30
  config.show_tab_index_in_tab_bar = true
  config.tab_bar_at_bottom = false
  config.tab_and_split_indices_are_zero_based = false
  config.hide_tab_bar_if_only_one_tab = true

  config.window_close_confirmation = "NeverPrompt"

  config.status_update_interval = 1000

  config.default_cursor_style = "SteadyBlock"
  config.window_decorations = "RESIZE"
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }

  config.inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 1.0,
  }
end

return mod
