local wezterm = require("wezterm")

local mod = {}

function mod.with_options(config)
  -- Tab bar
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

  -- Updates
  config.status_update_interval = 1000

  -- Appearance
  config.default_cursor_style = "SteadyBlock"
  config.window_decorations = "RESIZE"
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
end

-- Side effects
wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local scheme = overrides.color_scheme or window:effective_config().color_scheme

  -- Define colors
  local fg_workspace = (scheme == "dayfox") and "#333333" or "#63cdcf"
  local fg_leader = "#dbc074" -- Set your preferred color for the LEADER text here

  local workspace = window:active_workspace()

  -- Build the format table
  local status_table = {}

  if window:leader_is_active() then
    table.insert(status_table, { Foreground = { Color = fg_leader } })
    table.insert(status_table, { Text = " leader  " })
  end

  table.insert(status_table, { Foreground = { Color = fg_workspace } })
  table.insert(status_table, { Text = " " .. workspace .. " " })

  window:set_right_status(wezterm.format(status_table))
end)

return mod
