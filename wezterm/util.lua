local wezterm = require("wezterm")
local act = wezterm.action
local act_callback = wezterm.action_callback
local mod = {}

function mod.concat(table1, table2)
  local result = {}

  for _, value in ipairs(table1) do
    table.insert(result, value)
  end

  for _, value in ipairs(table2) do
    table.insert(result, value)
  end

  return result -- Return the concatenated table
end

function mod.filter(tbl, callback)
  local filt_table = {}
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(filt_table, v)
    end
  end
  return filt_table
end

function mod.kill_workspace_ui()
  return act_callback(function(win, pane)
    local current = win:active_workspace()
    local workspaces = wezterm.mux.get_workspace_names()
    local choices = {}

    for _, name in ipairs(workspaces) do
      table.insert(choices, { label = name, id = name })
    end

    win:perform_action(
      act.InputSelector({
        title = "Kill Workspace",
        fuzzy_description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Teal" } },
          { Text = "Fuzzy match workspace to kill: " },
        }),
        choices = choices,
        fuzzy = true,
        action = act_callback(function(inner_win, inner_pane, id, _)
          if not id then
            return
          end

          local do_kill = function(workspace_name)
            local success, stdout = wezterm.run_child_process({ "wezterm", "cli", "list", "--format=json" })
            if success then
              local json = wezterm.json_parse(stdout)
              local panes = mod.filter(json, function(p)
                return p.workspace == workspace_name
              end)
              for _, p in ipairs(panes) do
                wezterm.run_child_process({ "wezterm", "cli", "kill-pane", "--pane-id=" .. p.pane_id })
              end
              inner_win:toast_notification("Workspace", "Killed: " .. workspace_name, nil, 3000)
            end
          end

          -- If target is current, switch to 0_default first
          if id == current then
            inner_win:perform_action(act.SwitchToWorkspace({ name = "0_default" }), inner_pane)
            wezterm.sleep_ms(100)
            do_kill(id)
          else
            do_kill(id)
          end
        end),
      }),
      pane
    )
  end)
end

return mod
