return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "tokyonight",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "snacks_dashboard", "TelescopePrompt", "TelescopeResults", "oil", "snacks_terminal" },
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
				lualine_c = {
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_x = { "filetype" },
				lualine_y = { "lsp_status" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
