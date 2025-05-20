return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "everforest",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "snacks_dashboard" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "buffers" },
				lualine_b = { { "branch", icon = "󰘬" } },
				lualine_c = { "diff", "diagnostics" },
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
