return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
			local opts = {
				hook = {
					on_filetype = function()
						vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
					end,
				},
				R_args = { "--quiet", "--no-save" },
				min_editor_width = 72,
				rconsole_width = 78,
				objbr_mappings = { -- Object browser keymap
					c = "class", -- Call R functions
					["<localleader>gg"] = "head({object}, n = 15)", -- Use {object} notation to write arbitrary R code.
					v = function()
						-- Run lua functions
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

	{
		"R-nvim/cmp-r",
		{
			"hrsh7th/nvim-cmp",
			config = function()
				require("cmp").setup({ sources = { { name = "cmp_r" } } })
				require("cmp_r").setup({})
			end,
		},
	},
}
