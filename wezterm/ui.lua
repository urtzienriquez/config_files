local wezterm = require("wezterm")

local mod = {}

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
end

wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local scheme = overrides.color_scheme or window:effective_config().color_scheme

  local fg_workspace = (scheme == "dayfox") and "#333333" or "#63cdcf"
  local fg_leader = "#dbc074"
  local fg_copy_mode = "#f29e74"
  local fg_search_mode = "Fuchsia"

  local workspace = window:active_workspace()
  local status_table = {}

  if window:leader_is_active() then
    table.insert(status_table, { Foreground = { Color = fg_leader } })
    table.insert(status_table, { Text = " leader  " })
  end

  if window:active_key_table() == "copy_mode" then
    table.insert(status_table, { Foreground = { Color = fg_copy_mode } })
    table.insert(status_table, { Text = " copy  " })
  end

  if window:active_key_table() == "search_mode" then
    table.insert(status_table, { Foreground = { AnsiColor = fg_search_mode } })
    table.insert(status_table, { Text = " search  " })
  end

  table.insert(status_table, { Foreground = { Color = fg_workspace } })
  table.insert(status_table, { Text = " " .. workspace .. " " })

  window:set_right_status(wezterm.format(status_table))
end)

return mod
