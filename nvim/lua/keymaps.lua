-- ========================================
-- CENTRALIZED KEYMAPS CONFIGURATION
-- ========================================

-- Basic keymaps (available immediately)
-- ========================================

-- Escape as jj
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc using jj" })

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

-- Better paste that doesn't overwrite register in visual mode
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

-- Delete to black hole register (doesn't overwrite clipboard)
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete to black hole register" })
vim.keymap.set("n", "<leader>D", [["_D]], { desc = "Delete line to black hole register" })
vim.keymap.set("n", "<leader>x", [["_x]], { desc = "Delete char to black hole register" })

-- Better line movement (move lines up/down)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

-- Buffer navigation improvements
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Better search centering and n/N behavior
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better Y behavior (yank to end of line like C and D)
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Visual line navigation for wrapped lines
-- only have this behavior in markdown files
vim.api.nvim_create_autocmd("FileType", {
pattern = { 
        "markdown", 
        "text", 
        "rmd", "Rmd",           -- R Markdown
        "jmd", "Jmd",           -- Julia Markdown (Weave.jl)
        "quarto", "qmd", "Qmd", -- Quarto
        "org",                  -- Org-mode files
        "rst",                  -- reStructuredText
        "asciidoc", "adoc",     -- AsciiDoc
        "tex", "latex",         -- LaTeX files
        "wiki",                 -- Wiki files
        "textile",              -- Textile markup
        "mail",                 -- Email files
        "gitcommit",            -- Git commit messages
    },
    callback = function()
        local opts = { buffer = true }
        vim.keymap.set("n", "j", "gj", vim.tbl_extend("force", opts, { desc = "Move down by visual line" }))
        vim.keymap.set("n", "k", "gk", vim.tbl_extend("force", opts, { desc = "Move up by visual line" }))
        vim.keymap.set("v", "j", "gj", vim.tbl_extend("force", opts, { desc = "Move down by visual line" }))
        vim.keymap.set("v", "k", "gk", vim.tbl_extend("force", opts, { desc = "Move up by visual line" }))
        
        -- Keep original behavior accessible
        vim.keymap.set("n", "gj", "j", vim.tbl_extend("force", opts, { desc = "Move down by logical line" }))
        vim.keymap.set("n", "gk", "k", vim.tbl_extend("force", opts, { desc = "Move up by logical line" }))
    end,
})
-- ========================================
-- PLUGIN-DEPENDENT KEYMAPS
-- ========================================

-- Create autocommands that will set up keymaps after plugins load
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- ========================================
		-- UFO (code folding) keymaps
		-- ========================================
		local ufo_ok, ufo = pcall(require, "ufo")
		if ufo_ok then
			vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
		end

		-- ========================================
		-- Oil file explorer keymaps
		-- ========================================
		local oil_ok, oil = pcall(require, "oil")
		if oil_ok then
			vim.keymap.set("n", "<leader>-", function()
				if vim.bo.filetype == "oil" then
					oil.close()
				else
					oil.open()
				end
			end, { desc = "Toggle Oil file explorer" })
		end

		-- ========================================
		-- Snacks picker (fuzzy finding) keymaps
		-- ========================================
		if _G.Snacks and _G.Snacks.picker then
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
      vim.keymap.set("n", "<leader>fw", function() 
        Snacks.picker.spelling() 
      end, { desc = "Find spell suggestions" })
		end

		-- ========================================
		-- Conform (formatting) keymaps
		-- ========================================
		local conform_ok, conform = pcall(require, "conform")
		if conform_ok then
			vim.keymap.set({ "n", "v" }, "<leader>bf", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 50000,
				})
			end, { desc = "Format file or range" })
		end

		-- ========================================
		-- Tmux Navigator keymaps
		-- ========================================
		vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate left (tmux)" })
		vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate down (tmux)" })
		vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate up (tmux)" })
		vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate right (tmux)" })
		vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Navigate previous (tmux)" })

		-- ========================================
		-- Snacks (misc) keymaps
		-- ========================================
		if _G.Snacks then
			-- Zen mode
			vim.keymap.set("n", "<leader>z", function()
				Snacks.zen()
			end, { desc = "Toggle Zen Mode" })
			vim.keymap.set("n", "<leader>Z", function()
				Snacks.zen.zoom()
			end, { desc = "Toggle Zoom" })

			-- Scratch buffer
			vim.keymap.set("n", "<leader>.", function()
				Snacks.scratch()
			end, { desc = "Toggle Scratch Buffer" })
			vim.keymap.set("n", "<leader>S", function()
				Snacks.scratch.select()
			end, { desc = "Select Scratch Buffer" })

			-- Notifications
			vim.keymap.set("n", "<leader>n", function()
				Snacks.notifier.show_history()
			end, { desc = "Notification History" })
			vim.keymap.set("n", "<leader>un", function()
				Snacks.notifier.hide()
			end, { desc = "Dismiss All Notifications" })

			-- Buffer management
			vim.keymap.set("n", "<leader>bd", function()
				Snacks.bufdelete()
			end, { desc = "Delete Buffer" })

			-- File operations
			vim.keymap.set("n", "<leader>R", function()
				Snacks.rename.rename_file()
			end, { desc = "Rename File" })

			-- Git
			vim.keymap.set({ "n", "v" }, "<leader>gB", function()
				Snacks.gitbrowse()
			end, { desc = "Git Browse" })
			vim.keymap.set("n", "<leader>ll", function()
				Snacks.lazygit.log()
			end, { desc = "Lazygit log" })
			vim.keymap.set("n", "<leader>lg", function()
				Snacks.lazygit()
			end, { desc = "Lazygit" })

			-- Terminal
			vim.keymap.set("n", "<leader>t", function()
				Snacks.terminal()
			end, { desc = "Toggle Terminal" })

			-- Word jumping
			vim.keymap.set({ "n", "t" }, "]]", function()
				Snacks.words.jump(vim.v.count1)
			end, { desc = "Next Reference" })
			vim.keymap.set({ "n", "t" }, "[[", function()
				Snacks.words.jump(-vim.v.count1)
			end, { desc = "Prev Reference" })

			-- Neovim news
			vim.keymap.set("n", "<leader>N", function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end, { desc = "Neovim News" })
		end
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
-- WHICH-KEY GROUPS AND ORGANIZATION
-- ========================================
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		local wk_ok, wk = pcall(require, "which-key")
		if wk_ok then
			wk.add({
				-- Main groups
				{ "<leader>f", group = "Find" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Close REPL" },
				{ "<leader>g", group = "Git" },
				{ "<leader>l", group = "Lazygit" },
				{ "<leader>o", group = "Open REPL" },
				{ "<leader>r", group = "Render" },
				{ "<leader>s", group = "Send/Sync" },
				{ "<leader>u", group = "UI toggle" },

				-- Specific mappings for better organization
				{ "<leader>or", desc = "Open R REPL" },
				{ "<leader>op", desc = "Open Python REPL" },
				{ "<leader>oj", desc = "Open Julia REPL" },
				{ "<leader>om", desc = "Open MATLAB REPL" },
				{ "<leader>cr", desc = "Close REPL" },

				{ "<leader>ff", desc = "Find files" },
				{ "<leader>fb", desc = "Find buffers" },
				{ "<leader>fg", desc = "Find with grep" },
				{ "<leader>fG", desc = "Grep in buffers" },
				{ "<leader>fd", desc = "Find diagnostics" },
				{ "<leader>fk", desc = "Find keymaps" },
				{ "<leader>fs", desc = "Smart find" },

				{ "<leader>bf", desc = "Format buffer" },
				{ "<leader>bd", desc = "Delete buffer" },

				{ "<leader>sd", desc = "Sync directory" },
				{ "<leader>sx", desc = "Send cell" },
				{ "<leader>sb", desc = "Send buffer" },

				{ "<leader>rr", desc = "Render document" },

				{ "<leader>lg", desc = "Lazygit" },
				{ "<leader>ll", desc = "Lazygit log" },
				{ "<leader>gB", desc = "Git browse" },
			})
		end
	end,
})
