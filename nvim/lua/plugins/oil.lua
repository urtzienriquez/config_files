return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
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
    },
		view_options = { show_hidden = false },
		win_options = {
			signcolumn = "yes:2",
		},
	},
}
