return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	lazy = false,
	opts = {
		default_file_explorer = true,
		columns = {
			"icon",
			-- "permissions",
			-- "size",
			-- "mtime"
		},
		use_default_keymaps = true,
		view_options = { show_hidden = false },
		win_options = {
			signcolumn = "yes:2",
		},
	},
}
