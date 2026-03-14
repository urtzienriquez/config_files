local wezterm = require("wezterm")
local util = require("util")

local act = wezterm.action

local mod = {}

function mod.with_options(config)
  local keyBindings = {
    {
      key = 'f',
      mods = 'LEADER',
      action = wezterm.action.SpawnCommandInNewTab {
        -- We use a small script or direct command to launch fzf
        args = {
          'zsh', '-c',
          'fzf --height=85% --layout=reverse --border=rounded > /tmp/fzf_result && nvim $(cat /tmp/fzf_result)'
        },
        -- This ensures it spawns in a way that respects your window configuration
        domain = 'CurrentPaneDomain',
      },
    },
    {
      key = "b",
      mods = "LEADER",
      action = wezterm.action.EmitEvent("toggle-colorscheme"),
    },
    -- tmux behavior
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
      -- Create new tab
      key = "c",
      mods = "LEADER",
      action = act.SpawnTab("CurrentPaneDomain"),
    },
    {
      -- Previous tab
      key = "h",
      mods = "ALT",
      action = act.ActivateTabRelative(-1),
    },
    {
      -- Next tab
      key = "l",
      mods = "ALT",
      action = act.ActivateTabRelative(1),
    },
    {
      -- Tab navigator
      key = "t",
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
      -- Force close current tab
      key = "x",
      mods = "LEADER",
      action = act.CloseCurrentPane({ confirm = false }),
    },
    {
      -- Swap panes
      key = "{",
      mods = "LEADER|SHIFT",
      action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
    },
    -- {
    -- 	-- Go to previous pane
    -- 	key = ";",
    -- 	mods = "LEADER",
    -- 	action = act.ActivatePaneDirection("Prev"),
    -- },
    -- {
    -- 	-- Go to next pane
    -- 	key = "o",
    -- 	mods = "LEADER",
    -- 	action = act.ActivatePaneDirection("Next"),
    -- },
    {
      -- Vertical split
      key = "v",
      mods = "LEADER",
      action = act.SplitPane({
        direction = "Right",
        size = { Percent = 50 },
      }),
    },
    {
      -- Horizontal split
      key = "s",
      mods = "LEADER",
      action = act.SplitPane({
        direction = "Down",
        size = { Percent = 50 },
      }),
    },

    -- Workspaces

    {
      -- Create and activate a new workspace
      key = "w",
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

  -- Programmatically define key bindings for activating
  -- tabs by index.

  for i = 0, 8 do
    table.insert(keyBindings, {
      key = tostring(i),
      mods = "LEADER",
      action = act.ActivateTab(i),
    })
  end

  config.keys = util.concat(config.keys, keyBindings)
  config.use_dead_keys = true
  config.send_composed_key_when_left_alt_is_pressed = true
  config.send_composed_key_when_right_alt_is_pressed = true
end

return mod
