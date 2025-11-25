return {
	"stevearc/oil.nvim",
	dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
	lazy = false,
	opts = {
		default_file_explorer = true,
		use_default_keymaps = true,
		keymaps = {
			["t"] = { "actions.parent", mode = "n" },
			["<C-h>"] = false,
			["<C-l>"] = false,
			["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
			["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
			["<leader>l"] = "actions.refresh",
		},
	},
}
