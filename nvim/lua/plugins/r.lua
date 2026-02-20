return {
	{
		"R-nvim/R.nvim",
		ft = { "r", "rmd", "rnoweb", "quarto" },
		config = function()
			local function set_rnvim_keymaps()
				local opts_keymap = { noremap = true, silent = true, buffer = true }

				vim.keymap.set("n", "<leader>or", "<Plug>RStart", opts_keymap)
				vim.keymap.set("n", "<leader>qr", "<Plug>RClose", opts_keymap)
				vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", opts_keymap)
				vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts_keymap)
				vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts_keymap)
				vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", opts_keymap)
				vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", opts_keymap)
				vim.keymap.set("n", "<leader>ro", "<Plug>ROBToggle", opts_keymap)
				vim.keymap.set("n", "<leader>cn", "<Plug>RNextRChunk", opts_keymap)
				vim.keymap.set("n", "<leader>cN", "<Plug>RPreviousRChunk", opts_keymap)

				vim.keymap.set("n", "<leader>rr", function()
					local filename = vim.fn.input({
						prompt = "Output filename (without extension): ",
						cancelreturn = "__CANCEL__",
					})
					vim.api.nvim_echo({}, false, {})
					if filename == "__CANCEL__" then
						return
					end
					vim.cmd('RSend if(exists("params")) rm(params)')
					if filename ~= "" then
						vim.cmd(
							'RSend rmarkdown::render("'
								.. vim.fn.expand("%")
								.. '", output_file = "'
								.. filename
								.. '")'
						)
					else
						vim.cmd('RSend rmarkdown::render("' .. vim.fn.expand("%") .. '")')
					end
				end, { desc = "Render R Markdown with custom output name" })

				vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", opts_keymap)
				vim.keymap.set(
					"n",
					"<leader>ac",
					"i`r<Space>`<Esc>i",
					vim.tbl_extend("force", opts_keymap, { desc = "Add inline code" })
				)
			end

			local opts = {
				R_app = "R",
				external_term = "tmux split-window -d -h",
				bracketed_paste = true,
				R_args = { "--no-save --silent" },
				user_maps_only = true,
				r_ls = {
					completion = true,
					hover = true,
					signature = true,
					implementation = false,
					definition = false,
					references = false,
				},
				objbr_mappings = {
					c = "class",
					["<leader>gp"] = "head({object}, n = 15)",
					v = function()
						require("r.browser").toggle_view()
					end,
				},
				hook = {
					on_filetype = function()
						local ft = vim.bo.filetype
						if ft ~= "quarto" then
							set_rnvim_keymaps()
							return
						end
						local lines = vim.api.nvim_buf_get_lines(0, 0, 100, false)
						for _, line in ipairs(lines) do
							local lang = line:match("^```{(%w+)")
							if lang and lang:lower() == "r" then
								set_rnvim_keymaps()
								return
							end
						end
					end,
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
