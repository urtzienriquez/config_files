local wezterm = require("wezterm")

local mod = {}

function mod.with_options(config)
	config.font_size = 15.0
	config.freetype_load_target = "Light"
	config.line_height = 1.0
	config.font = wezterm.font("JetBrainsMonoNF")
end

return mod
