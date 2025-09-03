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
		local last_recorded_register = nil
		local recording_notification = nil

		-- When macro recording starts
		vim.api.nvim_create_autocmd("RecordingEnter", {
			group = macro_group,
			callback = function()
				local reg = vim.fn.reg_recording()
				last_recorded_register = reg

				-- First dismiss any existing macro notifications
				if recording_notification then
					pcall(function()
						require("notify").dismiss({ id = recording_notification.id })
					end)
				end

				-- Create new recording notification
				recording_notification = require("notify")(" Recording macro @" .. reg, vim.log.levels.INFO, {
					title = "Macro recording started",
					timeout = false,
				})
			end,
		})

		-- When macro recording stops
		vim.api.nvim_create_autocmd("RecordingLeave", {
			group = macro_group,
			callback = function()
				vim.defer_fn(function()
					-- Dismiss the recording notification first
					if recording_notification then
						pcall(function()
							require("notify").dismiss({ id = recording_notification.id })
						end)
					end

					-- Show completion notification
					if last_recorded_register then
						require("notify")(" Macro recorded @" .. last_recorded_register, vim.log.levels.INFO, {
							title = "Macro recording finished",
							timeout = 1500,
						})
					end

					-- Clean up
					last_recorded_register = nil
					recording_notification = nil
				end, 50)
			end,
		})
	end,
}
