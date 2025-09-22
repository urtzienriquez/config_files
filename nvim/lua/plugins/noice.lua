return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		lsp = {
			signature = { auto_open = { enabled = false } },
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		presets = {
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
			command_palette = false,
			bottom_search = true,
		},
		cmdline = {
			enabled = true,
			view = "cmdline", -- cmdline or cmdline_popup
			format = {
				cmdline = false,
				search_up = false,
				search_down = false,
				filter = false,
				input = false,
				lua = false,
				help = false,
			},
		},
	},
}
