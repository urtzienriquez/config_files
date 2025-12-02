-- nvim/lua/plugins/noice.lua
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline", -- Use classic cmdline view
			format = {
				cmdline = false,
				search_up = false,
				search_down = false,
				filter = false,
				-- input = false,
				lua = false,
				help = false,
			},
		},
		messages = {
			enabled = true,
			view = "mini", -- Use minimal message view
		},
		lsp = {
			override = {
				-- Override markdown rendering for hover docs
				["vim.lsp.util.convert_input_to_markdown_lines"] = false,
				["vim.lsp.util.stylize_markdown"] = false,
				["cmp.entry.get_documentation"] = false,
			},
			signature = {
				enabled = false, -- Disable if it causes issues
			},
		},
		presets = {
			bottom_search = false,
			command_palette = false,
			long_message_to_split = false,
			inc_rename = false,
			lsp_doc_border = false,
		},
		routes = {
			{
				-- Route long messages to split
				filter = {
					event = "msg_show",
					min_height = 10,
				},
				view = "split",
			},
			{
				-- Skip certain annoying messages
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
						{ find = "fewer lines" },
					},
				},
				opts = { skip = true },
			},
		},
	},
}
