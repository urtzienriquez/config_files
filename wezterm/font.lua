local wezterm = require("wezterm")
local mod = {}

_G.ligatures_enabled = true

local function toggle_ligatures(window)
  local overrides = window:get_config_overrides() or {}

  _G.ligatures_enabled = not _G.ligatures_enabled

  if _G.ligatures_enabled then
    overrides.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
  else
    overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
  end

  window:set_config_overrides(overrides)
end

function mod.with_options(config)
  config.font_size = 15.0
  config.freetype_load_target = "Light"
  config.line_height = 1.0
  config.font = wezterm.font("JetBrainsMonoNF")

  config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

  wezterm.on("toggle-ligatures", toggle_ligatures)
end

return mod
