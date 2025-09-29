return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				-- theme = "tokyonight",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					"snacks_dashboard",
					"TelescopePrompt",
					"TelescopeResults",
					"oil",
					"snacks_terminal",
				},
				globalstatus = false,
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
						color = { bg = "#82aaff" },
					},
				},
				lualine_b = { { "branch", icon = "󰘬", color = { fg = "#82aaff" } }, "diff" },
				lualine_c = {
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ffc777", gui = "bold" },
					},
				},
				lualine_x = { "filetype" },
				lualine_y = {},
				lualine_z = { { "progress", color = { bg = "#82aaff" } }, { "location", color = { bg = "#82aaff" } } },
			},
		})
	end,
}
