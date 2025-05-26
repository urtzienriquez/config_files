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
				lualine_a = { "buffers" },
				lualine_b = { { "branch", icon = "󰘬" }, "diff", "diagnostics" },
				lualine_c = {
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
