return {
	"stevearc/oil.nvim",
	dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
	lazy = false,
	opts = {
		default_file_explorer = true,
		use_default_keymaps = true,
		keymaps = {
			["t"] = { "actions.parent", mode = "n" },
		},
	},
}
