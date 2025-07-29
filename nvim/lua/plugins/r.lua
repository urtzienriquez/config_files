return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
			-- Set this as a global so R.nvim and radian can detect it properly
			local opts = {
				-- for r.nvim
				R_app = "radian",
				bracketed_paste = true,
				hook = {
					on_filetype = function()
						vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
					end,
				},
				-- These values are still valid here
				min_editor_width = 72,
				rconsole_width = 78,
				objbr_mappings = {
					c = "class",
					["<localleader>gg"] = "head({object}, n = 15)",
					v = function()
						require("r.browser").toggle_view()
					end,
				},
				disable_cmds = {
					"RClearConsole",
					"RCustomStart",
					"RSPlot",
					"RSaveClose",
				},
			}
			if vim.env.R_AUTO_START == "true" then
				opts.auto_start = "on startup"
				opts.objbr_auto_start = true
			end

			require("r").setup(opts)
		end,
	},
}
