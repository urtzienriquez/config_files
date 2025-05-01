return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	opts = {
		filesystem = {
			filtered_items = {
				visible = false, -- hide filtered items on open
				hide_gitignored = false,
				hide_dotfiles = false,
				never_show = { ".git" },
			},
		},
	},
}
