return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
		"hrsh7th/nvim-cmp",
	},
	opts = {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
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
				cmdline = { pattern = "^:", icon = ":", lang = "vim" },
			},
		},
	},
}
