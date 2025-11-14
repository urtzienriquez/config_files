return {
	"stevearc/oil.nvim",
	dependencies = { { "kyazdani42/nvim-web-devicons", opts = {} } },
	lazy = false,
	opts = {
		default_file_explorer = true,
		columns = {
			"icon",
		},
		use_default_keymaps = true,
		keymaps = {
			["t"] = { "actions.parent", mode = "n" },
			["<C-l>"] = false,
		},
		view_options = { show_hidden = true },
	},
}
