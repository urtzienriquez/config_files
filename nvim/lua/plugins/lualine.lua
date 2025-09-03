return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "nightfly",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "snacks_dashboard", "TelescopePrompt", "TelescopeResults" },
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
				lualine_x = {},
				lualine_y = { "filetype" },
				lualine_z = { "progress", "location" },
			},
		})
	end,
}
