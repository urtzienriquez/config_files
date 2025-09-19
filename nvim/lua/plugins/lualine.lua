return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "nightfly",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "snacks_dashboard", "TelescopePrompt", "TelescopeResults", "oil" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"filename",
						path = 0,
						symbols = {
							modified = "", -- remove [+]
							readonly = " ", -- remove [RO]
							unnamed = "[No Name]", -- still keep unnamed buffers readable
							newfile = "", -- remove [New]
						},
					},
				},
				lualine_b = { { "branch", icon = "󰘬" }, "diff", "diagnostics" },
				lualine_c = {},
				lualine_x = {
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_y = { "filetype" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
