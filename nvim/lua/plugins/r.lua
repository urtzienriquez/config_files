return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
			local opts = {
				R_app = "radian",
				external_term = "tmux split-window -d -h",
				bracketed_paste = true,
				hook = {
					on_filetype = function()
						vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})

						-- Clear any existing mappings first (optional)
						pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>rf")
						pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>ka")

						-- Set your custom mappings
						local opts_keymap = { noremap = true, silent = true }

						-- Your custom mapping: leader or instead of leader rf
						vim.api.nvim_buf_set_keymap(0, "n", "<leader>or", "<Plug>RStart", opts_keymap)
						vim.api.nvim_buf_set_keymap(0, "n", "<leader>sb", "<Plug>RSendFile", opts_keymap)
						vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", opts_keymap)
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", opts_keymap)
						vim.api.nvim_buf_set_keymap(0, "n", "<leader>qr", "<Plug>RClose", opts_keymap)
						vim.api.nvim_buf_set_keymap(0, "n", "<leader>rr", "<Plug>RMakeAll", opts_keymap)
					end,
				},
				R_args = { "--quiet", "--no-save" },
				min_editor_width = 72,
				rconsole_width = 78,
				objbr_mappings = { -- Object browser keymap
					c = "class", -- Call R functions
					["<leader>gg"] = "head({object}, n = 15)", -- Use {object} notation to write arbitrary R code.
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
					"RSeparatePath",
					"RFormatSubsetting",
					"RFormatNumbers",
					"RDputObj",
					"RSendChain",
					"RDSendCurrentFun",
					"RSendCurrentFun",
					"RSendAllFun",
					"RDSendMBlock",
					"RSendMBlock",
					"RSendMotion",
					"RDSendSelection",
					"RInsertLineOutput",
					"RInsertPipe",
					"RSendLine",
					"RDSendParagraph",
					"RSendParagraph",
					"RShowRout",
					"RMakeRmd",
					"RMakePDFKb",
					"RMakeHTML",
					"RMakeODT",
					"RMakePDFK",
					"RMakeWord",
					"RUndebug",
				},
			}
			if vim.env.R_AUTO_START == "true" then
				opts.auto_start = "on startup"
				opts.objbr_auto_start = true
			end
			require("r").setup(opts)

			-- Fix markdown code chunk background on colorscheme change
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					-- Adjust these highlight groups as needed for your colorscheme
        local bg = (vim.o.background == "dark") and "#292e42" or "#c4c8da"
        vim.cmd("hi! link rmdChunk CodeBlock")
        vim.cmd("hi! RCodeBlock guibg=" .. bg .. " guifg=NONE")
				end,
			})
		end,
	},
}
