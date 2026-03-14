local wezterm = require("wezterm")
local util = require("util")

local act = wezterm.action

local mod = {}

function mod.with_options(config)
  local keyBindings = {
    {
      key = "b",
      mods = "LEADER",
      action = wezterm.action.EmitEvent("toggle-colorscheme"),
    },
    {
      key = ";",
      mods = "LEADER",
      action = act.ActivateCopyMode,
    },
    {
      key = "z",
      mods = "LEADER",
      action = act.TogglePaneZoomState,
    },
    -- Pane and window management
    {
      key = "c", -- Create new tab
      mods = "LEADER",
      action = act.SpawnTab("CurrentPaneDomain"),
    },
    {
      key = "h", -- Previous tab
      mods = "ALT",
      action = act.ActivateTabRelative(-1),
    },
    {
      key = "l", -- Next tab
      mods = "ALT",
      action = act.ActivateTabRelative(1),
    },
    {
      key = "t", -- Tab navigator
      mods = "LEADER",
      action = act.ShowTabNavigator,
    },
    {
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Enter new name for tab",
        action = wezterm.action_callback(function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },
    {
      key = "x", -- Force close current tab
      mods = "LEADER",
      action = act.CloseCurrentPane({ confirm = false }),
    },
    {
      key = "{", -- Swap panes
      mods = "LEADER|SHIFT",
      action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
    },
    {
      key = "v", -- Vertical split
      mods = "LEADER",
      action = act.SplitPane({
        direction = "Right",
        size = { Percent = 50 },
      }),
    },
    {
      key = "s", -- Horizontal split
      mods = "LEADER",
      action = act.SplitPane({
        direction = "Down",
        size = { Percent = 50 },
      }),
    },
    -- Workspaces
    {
      key = "w", -- Create and activate a new workspace
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter name for new workspace" },
        }),
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace({
                name = line,
              }),
              pane
            )
          end
        end),
      }),
    },
  }
  -- activating tabs by index.
  for i = 1, 9 do
    table.insert(keyBindings, {
      key = tostring(i),
      mods = "LEADER",
      action = act.ActivateTab(i - 1),
    })
  end

  config.keys = util.concat(config.keys, keyBindings)
  config.use_dead_keys = true
  config.send_composed_key_when_left_alt_is_pressed = true
  config.send_composed_key_when_right_alt_is_pressed = true
end

return mod
