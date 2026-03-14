local wezterm = require("wezterm")
local act = wezterm.action

local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")

local mod = {}

function mod.with_options(config)
  -- optional: adds default keybindings from the plugin
  sessions.apply_to_config(config)

  -- Custom keybindings
  config.keys = config.keys or {}

  table.insert(config.keys, {
    key = "S",
    mods = "LEADER",
    action = act.EmitEvent("save_session"),
  })

  table.insert(config.keys, {
    key = "l",
    mods = "LEADER",
    action = act.EmitEvent("load_session"),
  })

  table.insert(config.keys, {
    key = "R",
    mods = "LEADER",
    action = act.EmitEvent("restore_session"),
  })

  table.insert(config.keys, {
    key = "K",
    mods = "LEADER",
    action = act.EmitEvent("delete_session"),
  })

  table.insert(config.keys, {
    key = "e",
    mods = "LEADER",
    action = act.EmitEvent("edit_session"),
  })
end

return mod
