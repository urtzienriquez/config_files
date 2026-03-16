local wezterm = require("wezterm")
local act = wezterm.action
local mod = {}

-- Helper to REPLACE an existing key and avoid shadowing the 'table' library
local function replace_key(tbl, key, mods, action)
  for i, binding in ipairs(tbl) do
    if binding.key == key and binding.mods == mods then
      table.remove(tbl, i)
      break
    end
  end
  table.insert(tbl, { key = key, mods = mods, action = action })
end

function mod.setup(config)
  local default_copy_mode = wezterm.gui.default_key_tables().copy_mode
  local default_search_mode = wezterm.gui.default_key_tables().search_mode

  -- Define a clean exit for reuse
  local clean_exit = act.Multiple({
    act.CopyMode("ClearPattern"),
    act.CopyMode("ClearSelectionMode"),
    act.CopyMode("Close"),
  })

  -- --- Copy Mode Overrides ---
  -- ESCAPE: Just deselect/clear pattern, stay in mode
  replace_key(
    default_copy_mode,
    "Escape",
    "NONE",
    act.Multiple({
      act.CopyMode("ClearPattern"),
      act.CopyMode("ClearSelectionMode"),
    })
  )

  -- Q: The actual exit button
  replace_key(default_copy_mode, "q", "NONE", clean_exit)

  -- Y: Yank and exit
  replace_key(
    default_copy_mode,
    "y",
    "NONE",
    act.Multiple({
      act.CopyTo("Clipboard"),
      clean_exit,
    })
  )

  -- /: Blank search
  replace_key(
    default_copy_mode,
    "/",
    "NONE",
    act.Multiple({
      act.CopyMode("ClearPattern"),
      act.Search({ CaseInSensitiveString = "" }),
    })
  )

  -- Navigate search results while in Copy Mode
  replace_key(default_copy_mode, "n", "NONE", act.CopyMode("NextMatch"))
  replace_key(default_copy_mode, "N", "SHIFT", act.CopyMode("PriorMatch"))
  replace_key(default_copy_mode, "n", "CTRL", act.CopyMode("NextMatch"))
  replace_key(default_copy_mode, "p", "CTRL", act.CopyMode("PriorMatch"))

  -- --- Search Mode Overrides ---
  replace_key(
    default_search_mode,
    "Enter",
    "NONE",
    act.Multiple({
      act.CopyMode("AcceptPattern"),
      act.CopyMode("ClearSelectionMode"),
    })
  )
  replace_key(default_search_mode, "Escape", "NONE", clean_exit)
  replace_key(default_search_mode, "c", "CTRL", clean_exit)

  config.key_tables = {
    copy_mode = default_copy_mode,
    search_mode = default_search_mode,
  }
end

return mod
