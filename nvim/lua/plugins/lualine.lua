return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "kyazdani42/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
        theme = "iceberg",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					"",
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
					},
				},
				lualine_b = { },
				lualine_c = {
					{ "branch", icon = "󰘬", },
					{ "diff"},
					{ "diagnostics"},
				},
				lualine_x = { "filetype" },
				lualine_y = {},
				lualine_z = { { "progress" }, { "location" } },
			},
		})
	end,
}
