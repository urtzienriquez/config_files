return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline",
			format = {
				cmdline = false,
				search_up = false,
				search_down = false,
				filter = false,
				input = {
					view = "cmdline",
				},
				lua = false,
				help = false,
			},
		},
		messages = {
			enabled = true,
			view = "mini",
		},
		lsp = {
			signature = {
				enabled = false,
			},
		},
		presets = {
			bottom_search = false,
			command_palette = false,
			long_message_to_split = false,
			inc_rename = false,
			lsp_doc_border = true,
		},
	},
}
