return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
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
							modified = "",
							readonly = " ",
							unnamed = "[No Name]",
							newfile = "",
						},
						color = { bg = "#82aaff" },
					},
				},
				lualine_b = {
					{ "branch", icon = "󰘬", color = { fg = "#82aaff", bg = "#1e2030" } },
					{ "diff", color = { bg = "#1e2030" } },
					{ "diagnostics", color = { bg = "#1e2030" } },
				},
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
