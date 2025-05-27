return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "nightfly",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "snacks_dashboard" },
				globalstatus = true,
			},
			sections = {
				-- Add the macro recording status in the mode section
				lualine_a = {
					function()
						local reg = vim.fn.reg_recording()
						-- If a macro is being recorded, show "Recording @<register>"
						if reg ~= "" then
							return "Recording @" .. reg
						else
							-- Get the full mode name using nvim_get_mode()
							local mode = vim.api.nvim_get_mode().mode
							local mode_map = {
								n = "NORMAL",
								nt = "NORMAL",
								i = "INSERT",
								v = "VISUAL",
								V = "V-LINE",
								["\22"] = "V-BLOCK",
								c = "COMMAND",
								R = "REPLACE",
								s = "SELECT",
								S = "S-LINE",
								["\19"] = "S-BLOCK",
								t = "TERMINAL",
							}

							-- Return the full mode name
							return mode_map[mode] or mode:upper()
						end
					end,
				},
				lualine_b = { "buffers" },
				lualine_c = { { "branch", icon = "󰘬" }, "diff", "diagnostics" },
				-- lualine_c = {
				-- 	{
				-- 		require("noice").api.statusline.mode.get,
				-- 		cond = require("noice").api.statusline.mode.has,
				-- 		color = { fg = "#ff9e64" },
				-- 	},
				-- },
				lualine_x = {},
				lualine_y = { "filetype" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
