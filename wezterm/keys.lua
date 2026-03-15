local wezterm = require("wezterm")
local util = require("util")

local act = wezterm.action
local act_callback = wezterm.action_callback

local mod = {}

-- Track tab bar visibility state for single tab
local hide_single_tab = true -- Matches your config.hide_tab_bar_if_only_one_tab

wezterm.on("toggle-tab-bar", function(window, pane)
  hide_single_tab = not hide_single_tab
  window:set_config_overrides({
    enable_tab_bar = true, -- Always enabled for multiple tabs
    hide_tab_bar_if_only_one_tab = hide_single_tab
  })
end)

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
      key = "t",
      mods = "LEADER",
      action = wezterm.action.EmitEvent("toggle-tab-bar"),
    },
    {
      key = "[",
      mods = "LEADER",
      action = wezterm.action_callback(function(window, pane)
        local original_pane_id = pane:pane_id()
        window:perform_action(act.RotatePanes("CounterClockwise"), pane)
        local tab = window:active_tab()
        for _, p in ipairs(tab:panes()) do
          if p:pane_id() == original_pane_id then
            p:activate()
            break
          end
        end
      end),
    },
    {
      key = "]",
      mods = "LEADER",
      action = wezterm.action_callback(function(window, pane)
        local original_pane_id = pane:pane_id()
        window:perform_action(act.RotatePanes("Clockwise"), pane)
        local tab = window:active_tab()
        for _, p in ipairs(tab:panes()) do
          if p:pane_id() == original_pane_id then
            p:activate()
            break
          end
        end
      end),
    },
    -- tabs
    {
      key = "'",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Teal" } },
          { Text = "Enter tab position: " },
        }),
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            -- Convert to 0-based index for MoveTab
            local position = tonumber(line)
            if position and position > 0 then
              window:perform_action(act.MoveTab(position - 1), pane)
            end
          end
        end),
      }),
    },
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
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Teal" } },
          { Text = "Enter new name for tab" },
        }),
        action = act_callback(function(window, _, line)
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
    {
      key = "o",
      mods = "LEADER",
      action = act_callback(function(win, pane)
        local tab = win:active_tab()
        for _, p in ipairs(tab:panes()) do
          if p:pane_id() ~= pane:pane_id() then
            p:activate()
            win:perform_action(act.CloseCurrentPane({ confirm = false }), p)
          end
        end
      end),
    },
    -- Workspaces
    {
      key = "w", -- Create and activate a new workspace
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Teal" } },
          { Text = "New workspace. Enter name:" },
        }),
        action = act_callback(function(window, pane, line)
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
    {
      key = "r",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Teal" } },
          { Text = "Rename workspace" },
        }),
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(window:active_workspace(), line)
          end
        end),
      }),
    },
    {
      key = "X",
      mods = "LEADER",
      action = util.kill_workspace_ui(), -- One clean call
    },
    {
      key = "K",
      mods = "LEADER",
      -- Replace the pkill command with this:
      action = wezterm.action.QuitApplication,
    },
    {
      key = "F12",
      mods = "",
      action = act.ShowDebugOverlay,
      -- to update plugins in debugoverlay run:
      -- wezterm.plugin.update_all()
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
