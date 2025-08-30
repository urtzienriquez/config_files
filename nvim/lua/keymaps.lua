-- ========================================
-- CENTRALIZED KEYMAPS CONFIGURATION
-- ========================================

-- Basic keymaps (available immediately)
-- ========================================

-- Escape as jj
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc using jj" })

-- Word suggestions in normal mode
vim.keymap.set("n", "<C-x><C-s>", "i<C-X><C-S>", { desc = "Spelling suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-n>", "i<C-X><C-N>", { desc = "Next word suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-p>", "i<C-X><C-P>", { desc = "Previous word suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-x>", "i<C-X><C-O>", { desc = "Omni suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-k>", "i<C-X><C-K>", { desc = "Dictionary suggestion in normal mode" })

-- Escape terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Resize windows
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>", { silent = true, desc = "Resize vertically split window" })
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>", { silent = true, desc = "Resize vertically split window" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "Resize horizontally split window" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "Resize horizontally split window" })

-- Split windows (i3-style)
vim.keymap.set("n", "<C-w>v", ":split<CR>", { desc = "Vertically split window as in i3" })
vim.keymap.set("n", "<C-w>h", ":vs<CR>", { desc = "Horizontally split window as in i3" })

-- Remap half page up/down to center cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Jump half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Jump half page up" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ========================================
-- LSP KEYMAPS (set when LSP attaches)
-- ========================================
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Information hover" }))
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
	end,
})

-- ========================================
-- PLUGIN KEYMAPS SETUP
-- ========================================

-- Simple function to set up keymaps with multiple attempts
local function setup_plugin_keymaps()
	local max_attempts = 30
	local attempt = 0

	local function try_setup()
		attempt = attempt + 1

		-- UFO keymaps
		local ufo_ok, ufo = pcall(require, "ufo")
		if
			ufo_ok
			and not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "zR"
				end, vim.api.nvim_get_keymap("n")))
				== false
		then
			vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
		end

		-- Oil keymaps
		local oil_ok, oil = pcall(require, "oil")
		if
			oil_ok
			and not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "<Leader>-"
				end, vim.api.nvim_get_keymap("n")))
				== false
		then
			vim.keymap.set("n", "<leader>-", function()
				if vim.bo.filetype == "oil" then
					oil.close()
				else
					oil.open()
				end
			end, { desc = "Toggle Oil file explorer" })
		end

		-- Snacks keymaps
		if _G.Snacks then
			if
				_G.Snacks.picker
				and not vim.tbl_isempty(vim.tbl_filter(function(k)
						return k.lhs == "<Leader>ff"
					end, vim.api.nvim_get_keymap("n")))
					== false
			then
				vim.keymap.set("n", "<leader>fs", function()
					Snacks.picker.smart()
				end, { desc = "Smart files" })
				vim.keymap.set("n", "<leader>ff", function()
					Snacks.picker.files()
				end, { desc = "Find files" })
				vim.keymap.set("n", "<leader>fb", function()
					Snacks.picker.buffers({
						win = { input = { keys = { ["<C-d>"] = { "bufdelete", mode = { "i", "n" } } } } },
					})
				end, { desc = "Find buffers" })
				vim.keymap.set("n", "<leader>fg", function()
					Snacks.picker.grep()
				end, { desc = "Find grep" })
				vim.keymap.set("n", "<leader>fG", function()
					Snacks.picker.grep_buffers()
				end, { desc = "Grep in buffers" })
				vim.keymap.set("n", "<leader>fd", function()
					Snacks.picker.diagnostics_buffer()
				end, { desc = "Find diagnostics" })
				vim.keymap.set("n", "<leader>fk", function()
					Snacks.picker.keymaps()
				end, { desc = "Find keymaps" })
			end

			-- Other Snacks functions
			if
				not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "<Leader>z"
				end, vim.api.nvim_get_keymap("n"))) == false
			then
				vim.keymap.set("n", "<leader>z", function()
					Snacks.zen()
				end, { desc = "Toggle Zen Mode" })
				vim.keymap.set("n", "<leader>Z", function()
					Snacks.zen.zoom()
				end, { desc = "Toggle Zoom" })
				vim.keymap.set("n", "<leader>.", function()
					Snacks.scratch()
				end, { desc = "Toggle Scratch Buffer" })
				vim.keymap.set("n", "<leader>S", function()
					Snacks.scratch.select()
				end, { desc = "Select Scratch Buffer" })
				vim.keymap.set("n", "<leader>n", function()
					Snacks.notifier.show_history()
				end, { desc = "Notification History" })
				vim.keymap.set("n", "<leader>un", function()
					Snacks.notifier.hide()
				end, { desc = "Dismiss All Notifications" })
				vim.keymap.set("n", "<leader>bd", function()
					Snacks.bufdelete()
				end, { desc = "Delete Buffer" })
				vim.keymap.set("n", "<leader>cR", function()
					Snacks.rename.rename_file()
				end, { desc = "Rename File" })
				vim.keymap.set({ "n", "v" }, "<leader>gB", function()
					Snacks.gitbrowse()
				end, { desc = "Git Browse" })
				vim.keymap.set("n", "<leader>ll", function()
					Snacks.lazygit.log()
				end, { desc = "Lazygit log" })
				vim.keymap.set("n", "<leader>lg", function()
					Snacks.lazygit()
				end, { desc = "Lazygit" })
				vim.keymap.set("n", "<leader>t", function()
					Snacks.terminal()
				end, { desc = "Toggle Terminal" })
				vim.keymap.set("n", "<c-_>", function()
					Snacks.terminal()
				end, { desc = "Toggle Terminal" })
				vim.keymap.set({ "n", "t" }, "]]", function()
					Snacks.words.jump(vim.v.count1)
				end, { desc = "Next Reference" })
				vim.keymap.set({ "n", "t" }, "[[", function()
					Snacks.words.jump(-vim.v.count1)
				end, { desc = "Prev Reference" })
				vim.keymap.set("n", "<leader>N", function()
					Snacks.win({
						file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
						width = 0.6,
						height = 0.6,
						wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
					})
				end, { desc = "Neovim News" })
			end
		end

		-- Conform keymaps
		local conform_ok, conform = pcall(require, "conform")
		if
			conform_ok
			and not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "<Leader>bf"
				end, vim.api.nvim_get_keymap("n")))
				== false
		then
			vim.keymap.set({ "n", "v" }, "<leader>bf", function()
				conform.format({ lsp_fallback = true, async = false, timeout_ms = 500 })
			end, { desc = "Format file or range" })
		end

		-- Tmux Navigator keymaps
		if
			vim.fn.exists(":TmuxNavigateLeft") == 2
			and not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "<C-H>"
				end, vim.api.nvim_get_keymap("n")))
				== false
		then
			vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Navigate left (tmux)" })
			vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Navigate down (tmux)" })
			vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Navigate up (tmux)" })
			vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Navigate right (tmux)" })
			vim.keymap.set("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Navigate previous (tmux)" })
		end

		-- Slime keymaps (global)
		if
			vim.fn.exists("*slime#send") == 1
			and _G.open_r_repl
			and not vim.tbl_isempty(vim.tbl_filter(function(k)
					return k.lhs == "<Leader>or"
				end, vim.api.nvim_get_keymap("n")))
				== false
		then
			vim.keymap.set("n", "<leader>or", _G.open_r_repl, { desc = "Open R (radian) REPL" })
			vim.keymap.set("n", "<leader>op", _G.open_python_repl, { desc = "Open Python REPL" })
			vim.keymap.set("n", "<leader>oj", _G.open_julia_repl, { desc = "Open Julia REPL" })
			vim.keymap.set("n", "<leader>om", _G.open_matlab_repl, { desc = "Open MATLAB REPL" })
			vim.keymap.set("n", "<leader>cr", _G.close_repl, { desc = "Close REPL" })
			vim.keymap.set("n", "<leader>sd", _G.sync_working_directory, { desc = "Sync REPL directory" })

			if vim.fn.exists(":SlimeConfig") == 2 then
				vim.keymap.set("n", "<leader>sc", "<Cmd>SlimeConfig<CR>", { desc = "Configure slime" })
			end

			vim.keymap.set("n", "<leader>rr", function()
				local filename = vim.fn.expand("%:t")
				if filename:match("%.rmd$") or filename:match("%.Rmd$") then
					if _G.render_rmarkdown then
						_G.render_rmarkdown()
					end
				elseif filename:match("%.jmd$") then
					if _G.render_jmarkdown then
						_G.render_jmarkdown()
					end
				elseif filename:match("%.qmd$") or filename:match("%.Qmd$") then
					if _G.render_quarto then
						_G.render_quarto()
					end
				else
					vim.notify("Not a renderable markdown file (.rmd, .jmd, or .qmd)", vim.log.levels.WARN)
				end
			end, { desc = "Render markdown document" })
		end

		-- Try again if not all plugins are ready
		if attempt < max_attempts then
			vim.defer_fn(try_setup, 500)
		else
			-- Set up which-key groups
			vim.defer_fn(function()
				local wk_ok, wk = pcall(require, "which-key")
				if wk_ok then
					wk.add({
						{ "<leader>f", group = "Find" },
						{ "<leader>b", group = "Buffer" },
						{ "<leader>c", group = "Code" },
						{ "<leader>g", group = "Git" },
						{ "<leader>l", group = "Lazy/Logs" },
						{ "<leader>o", group = "Open REPL" },
						{ "<leader>r", group = "Render/Run" },
						{ "<leader>s", group = "Send/Slime" },
						{ "<leader>u", group = "UI/Toggle" },
					})
				end
			end, 1000)
		end
	end

	-- Start trying to set up keymaps
	vim.defer_fn(try_setup, 1000)
end

-- Start setup after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		setup_plugin_keymaps()
	end,
})

-- ========================================
-- FILETYPE-SPECIFIC SLIME KEYMAPS
-- ========================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "julia", "r", "matlab", "markdown", "rmd", "quarto" },
	callback = function()
		local opts = { buffer = true, silent = true }
		local current_ft = vim.bo.filetype

		-- Set cell delimiter
		if current_ft == "matlab" then
			vim.b.slime_cell_delimiter = "%% "
		else
			vim.b.slime_cell_delimiter = "# %%"
		end

		-- Set up buffer-local slime keymaps with simple retry
		local function setup_buffer_keymaps()
			local attempts = 0
			local function try_buffer_setup()
				attempts = attempts + 1

				if vim.fn.exists("*slime#send") == 1 and _G.smart_send and _G.send_cell then
					-- Main smart send - Enter key
					vim.keymap.set("n", "<Enter>", function()
						_G.smart_send("n")
					end, vim.tbl_extend("force", opts, { desc = "Smart send" }))

					vim.keymap.set("v", "<Enter>", function()
						_G.smart_send("v")
					end, vim.tbl_extend("force", opts, { desc = "Send selection" }))

					-- Send cell
					vim.keymap.set(
						"n",
						"<leader>sx",
						_G.send_cell,
						vim.tbl_extend("force", opts, { desc = "Send cell" })
					)

					-- Send buffer
					if vim.fn.exists(":SlimeSend") == 2 then
						vim.keymap.set(
							"n",
							"<leader>sb",
							"<Cmd>%SlimeSend<CR>",
							vim.tbl_extend("force", opts, { desc = "Send buffer" })
						)
					end

					-- File-specific render keybinds
					local filename = vim.fn.expand("%:t")
					if filename:match("%.rmd$") or filename:match("%.Rmd$") then
						if _G.render_rmarkdown then
							vim.keymap.set(
								"n",
								"<leader>rr",
								_G.render_rmarkdown,
								vim.tbl_extend("force", opts, { desc = "Render R Markdown" })
							)
						end
					elseif filename:match("%.jmd$") then
						if _G.render_jmarkdown then
							vim.keymap.set(
								"n",
								"<leader>rr",
								_G.render_jmarkdown,
								vim.tbl_extend("force", opts, { desc = "Render Julia Markdown" })
							)
						end
					elseif filename:match("%.qmd$") or filename:match("%.Qmd$") then
						if _G.render_quarto then
							vim.keymap.set(
								"n",
								"<leader>rr",
								_G.render_quarto,
								vim.tbl_extend("force", opts, { desc = "Render Quarto" })
							)
						end
					end
				elseif attempts < 20 then
					vim.defer_fn(try_buffer_setup, 500)
				end
			end

			vim.defer_fn(try_buffer_setup, 500)
		end

		setup_buffer_keymaps()
	end,
})
