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
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
		},
		cmdline = {
			enabled = true,
			view = "cmdline",
			format = {
				cmdline = { pattern = "^:", icon = ":", lang = "vim" },
			},
		},
	},

	config = function(_, opts)
		local noice = require("noice")
		noice.setup(opts)

		local macro_group = vim.api.nvim_create_augroup("MacroRecording", { clear = true })
		local macro_id = "macro_recording"
		local last_recorded_register = nil

		-- When macro recording starts
		vim.api.nvim_create_autocmd("RecordingEnter", {
			group = macro_group,
			callback = function()
				local reg = vim.fn.reg_recording()
				last_recorded_register = reg

				require("noice").notify("Recording macro @" .. reg, "info", {
					title = "Macro Recording",
					timeout = false,
					replace = macro_id,
				})
			end,
		})

		-- When macro recording stops
		vim.api.nvim_create_autocmd("RecordingLeave", {
			group = macro_group,
			callback = function()
				vim.defer_fn(function()
					if last_recorded_register then
						require("noice").notify("Macro recorded @" .. last_recorded_register, "info", {
							title = "Macro Recording",
							timeout = 1500,
							replace = macro_id,
						})
					end
					last_recorded_register = nil
				end, 50)
			end,
		})
	end,
}
