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
		views = {
			mini = {
				timeout = 3000,
				win_options = {
					winblend = 0,
				},
			},
			split = { enter = true },
		},
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
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
		routes = {
			{
				filter = {
					event = "msg_show",
					min_height = 10,
				},
				view = "split",
			},
			{
				filter = {
					event = "msg_show",
					["not"] = {
						kind = "search_count",
					},
				},
				view = "mini",
			},
		},
	},
}
