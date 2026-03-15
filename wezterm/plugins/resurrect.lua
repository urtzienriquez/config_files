local wezterm = require("wezterm")
local util = require("util")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local mod = {}

local function load_state(win, pane)
  resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
    local type = string.match(id, "^([^/]+)")
    id = string.match(id, "([^/]+)$")
    id = string.match(id, "(.+)%..+$")

    local opts = {
      relative = true,
      restore_text = true,
      on_pane_restore = resurrect.tab_state.default_on_pane_restore,
      resize_window = false,
    }

    if type == "workspace" then
      local state = resurrect.state_manager.load_state(id, "workspace")

      resurrect.workspace_state.restore_workspace(state, {
        spawn_in_workspace = id,
        relative = true,
        restore_text = true,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        resize_window = false,
      })

      win:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane)
    elseif type == "window" then
      local state = resurrect.state_manager.load_state(id, "window")
      resurrect.window_state.restore_window(win:mux_window(), state, opts)
    end
  end)
end

function mod.with_options(config)
  local key_bindings = {
    {
      key = "S",
      mods = "LEADER",
      action = wezterm.action_callback(function(win, pane)
        local workspace_name = wezterm.mux.get_active_workspace()
        resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
        resurrect.state_manager.write_current_state(workspace_name, "workspace")
        win:toast_notification("Resurrect", "Saved: " .. workspace_name, nil, 3000)
      end),
    },
    {
      key = "l",
      mods = "LEADER",
      action = wezterm.action_callback(load_state),
    },
    {
      key = "D",
      mods = "LEADER",
      action = wezterm.action_callback(function(win, pane)
        resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
          resurrect.state_manager.delete_state(id)
        end)
      end),
    },
  }
  config.keys = util.concat(config.keys or {}, key_bindings)
end

return mod
