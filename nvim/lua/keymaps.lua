-- =========
-- KEYMAPS
-- =========

-- Basic keymaps
-- ===============

-- Disable arrow keys in normal and insert modes
vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true, silent = true })

-- Highlight without moving
vim.keymap.set("n", "*", "*``")

-- Escape terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- navigate quickfix
vim.keymap.set("n", "<Up>", "<cmd>cprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<cmd>cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<cmd>cclose<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<cmd>copen<CR>", { noremap = true, silent = true })

-- Resize windows
vim.keymap.set("n", "<C-A-Left>", ":vertical resize +2<CR>", { silent = true, desc = "Resize vertically split window" })
vim.keymap.set(
	"n",
	"<C-A-Right>",
	":vertical resize -2<CR>",
	{ silent = true, desc = "Resize vertically split window" }
)
vim.keymap.set("n", "<C-A-Up>", ":resize +2<CR>", { silent = true, desc = "Resize horizontally split window" })
vim.keymap.set("n", "<C-A-Down>", ":resize -2<CR>", { silent = true, desc = "Resize horizontally split window" })

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
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole register" })
vim.keymap.set("n", "<leader>D", [["_D]], { desc = "Delete line to black hole register" })
vim.keymap.set("n", "<leader>x", [["_x]], { desc = "Delete char to black hole register" })

-- Better line movement (move lines up/down)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

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
		"quarto",
		"rmd",
		"Rmd",
		"qmd",
		"Qmd", -- Quarto
		"org", -- Org-mode files
		"rst", -- reStructuredText
		"asciidoc",
		"adoc", -- AsciiDoc
		"tex",
		"latex", -- LaTeX files
		"wiki", -- Wiki files
		"textile", -- Textile markup
		"mail", -- Email files
		"gitcommit", -- Git commit messages
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

-- add all variants of a word to spellfile
vim.api.nvim_create_user_command("ZgVariants", function()
	local word = vim.fn.expand("<cword>")
	local variants = {
		word:lower(),
		word:sub(1, 1):upper() .. word:sub(2):lower(),
		word:upper(),
	}
	for _, v in ipairs(variants) do
		vim.cmd("silent spellgood " .. v) -- <- suppress messages
	end
	print("Added variants of '" .. word .. "' to spellfile")
end, {})

vim.keymap.set("n", "zg", ":ZgVariants<CR>", { noremap = true, silent = true })

-- ========================================
-- PLUGIN-DEPENDENT KEYMAPS
-- ========================================

-- Create autocommands that will set up keymaps after plugins load
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- ========================================
		-- Oil file explorer keymaps
		-- ========================================
		local oil_ok, oil = pcall(require, "oil")
		if oil_ok then
			vim.keymap.set("n", "<leader>t", function()
				if vim.bo.filetype == "oil" then
					oil.close()
				else
					oil.open()
				end
			end, { desc = "Toggle Oil file explorer" })
		end

		-- ========================================
		-- Telescope (fuzzy finding) keymaps
		-- ========================================

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>fp", builtin.builtin, { desc = "Find picker" })
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>f~", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~"),
				prompt_title = "Find files in home directory",
				hidden = true, -- Show hidden files
			})
		end, { desc = "Find files in home directory" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find with grep" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help tags" })
		vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
		vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word" })
		vim.keymap.set("n", "<leader>fdg", builtin.diagnostics, { desc = "Find diagnostics globally (in workspace)" })
		vim.keymap.set("n", "<leader>fdd", function()
			builtin.diagnostics({ bufnr = 0 })
		end, { desc = "Find diagnostics in current buffer" })
		vim.keymap.set("n", "<leader>fl", builtin.lsp_definitions, { desc = "Find lsp definitions" })
		vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find lsp document symbols" })
		vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Find treesitter symbols" })
		vim.keymap.set("n", "<leader>fm", builtin.spell_suggest, { desc = "Find (misspelled) spell suggestion" })
		vim.keymap.set("n", "<leader>f'", builtin.marks, { desc = "Find marks" })
		vim.keymap.set("n", "<leader>f,", builtin.resume, { desc = "Find resume" })
		vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = "Find recent files" })

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
		-- treesitter textobjects
		-- ========================================
		vim.keymap.set({ "x", "o" }, "af", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
		end, { desc = "around function" })
		vim.keymap.set({ "x", "o" }, "if", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
		end, { desc = "inside function" })
		vim.keymap.set({ "x", "o" }, "al", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
		end, { desc = "around loop" })
		vim.keymap.set({ "x", "o" }, "il", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
		end, { desc = "inside loop" })
		vim.keymap.set({ "x", "o" }, "ac", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
		end, { desc = "around conditional" })
		vim.keymap.set({ "x", "o" }, "ic", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
		end, { desc = "inside the condition" })

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
			vim.keymap.set("n", "<leader>Z", function()
				Snacks.zen()
			end, { desc = "Toggle Zen Mode" })
			vim.keymap.set("n", "<leader>z", function()
				Snacks.zen.zoom()
			end, { desc = "Toggle Zoom" })

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

			-- Word jumping
			vim.keymap.set({ "n", "t" }, "]]", function()
				Snacks.words.jump(vim.v.count1)
			end, { desc = "Next Reference" })
			vim.keymap.set({ "n", "t" }, "[[", function()
				Snacks.words.jump(-vim.v.count1)
			end, { desc = "Prev Reference" })
		end
	end,
})

-- ========================================
-- r.nvim
-- ========================================
local function set_rnvim_keymaps(bufnr)
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>rf")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>gn")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>gN")

	local opts_keymap = { noremap = true, silent = true, buffer = true }

	vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts_keymap)
	vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts_keymap)

	vim.keymap.set("n", "<leader>or", "<Plug>RStart", opts_keymap)
	vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", opts_keymap)
	vim.keymap.set("n", "<leader>qr", "<Plug>RClose", opts_keymap)
	vim.keymap.set("n", "<leader>rr", "<Plug>RMakeAll", opts_keymap)
	vim.keymap.set("n", "<leader>cn", "<Plug>RNextRChunk", opts_keymap)
	vim.keymap.set("n", "<leader>cN", "<Plug>RPreviousRChunk", opts_keymap)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "r", "rmd", "Rmd" },
	callback = function()
		set_rnvim_keymaps(0)
	end,
})

-- ========================================
-- vim-slime keymaps
-- ========================================
local slime_utils = require("slime_utils")

local function set_slime_keymaps(bufnr)
	local opts_keymap = { noremap = true, silent = true, buffer = true }

	-- Start REPLs
	vim.keymap.set("n", "<leader>op", function()
		slime_utils.start_tmux_repl("python")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start Python REPL" }))
	vim.keymap.set("n", "<leader>oj", function()
		slime_utils.start_tmux_repl("julia")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start Julia REPL" }))
	vim.keymap.set("n", "<leader>om", function()
		slime_utils.start_tmux_repl("matlab")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start MATLAB REPL" }))

	-- Send code
	vim.keymap.set("n", "<Return>", function()
		if slime_utils.has_active_repl() then
			local keys = "vai" .. vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, false, true) .. "'>j"
			vim.api.nvim_feedkeys(keys, "x", false)
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, { silent = true })
	vim.keymap.set("v", "<Return>", function()
		if slime_utils.has_active_repl() then
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, false, true),
				"x",
				false
			)
			vim.cmd("normal! '>j")
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, { silent = true })
	vim.keymap.set("n", "<leader>sb", function()
		if slime_utils.has_active_repl() then
			vim.cmd("normal! ggVG")
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, false, true),
				"x",
				false
			)
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Send entire buffer to REPL" }))

	-- Instantiate julia project
	vim.keymap.set("n", "<leader>ji", function()
		if slime_utils.has_active_repl() then
      local keys = "using Pkg; Pkg.activate(\".\")\nPkg.instantiate()\n"
			vim.fn["slime#send"](keys)
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, { silent = true, desc = "activate and instantiate julia project" })

	-- Sync working directory
	vim.keymap.set("n", "<leader>sd", function()
		if slime_utils.has_active_repl() then
			slime_utils.sync_working_directory()
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Sync working directory to REPL" }))

	-- Close REPLs
	vim.keymap.set("n", "<leader>qp", function()
		if slime_utils.has_active_repl() then
			slime_utils.close_tmux_repl("python")
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Close Python REPL" }))
	vim.keymap.set("n", "<leader>qj", function()
		if slime_utils.has_active_repl() then
			slime_utils.close_tmux_repl("julia")
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Close Julia REPL" }))
	vim.keymap.set("n", "<leader>qm", function()
		if slime_utils.has_active_repl() then
			slime_utils.close_tmux_repl("matlab")
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Close MATLAB REPL" }))
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "julia", "matlab" },
	callback = function()
		set_slime_keymaps(0)
	end,
})

-- ========================================
-- for quarto
-- ========================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "quarto" },
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
		local lang = nil
		for _, line in ipairs(lines) do
			local l = line:match("^```{(%w+)}")
			if l then
				lang = l:lower()
				break
			end
		end
		if lang == "r" then
			set_rnvim_keymaps(bufnr)
		elseif lang == "python" or lang == "julia" or lang == "matlab" then
			set_slime_keymaps(bufnr)
		end
	end,
})

-- ========================================
-- Citation Picker
-- ========================================
local citation = require("citation-picker")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "rmd", "Rmd", "quarto", "jmd", "Jmd", "tex", "pandoc" },
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set(
			"i",
			"<C-Space>",
			citation.citation_picker,
			vim.tbl_extend("force", opts, { desc = "Find citations (custom)" })
		)
		vim.keymap.set(
			"n",
			"<leader>fc",
			citation.citation_picker,
			vim.tbl_extend("force", opts, { desc = "Find citations (custom)" })
		)
		vim.keymap.set(
			"n",
			"<leader>fr",
			citation.citation_replace,
			vim.tbl_extend("force", opts, { desc = "Find replacement citation under cursor (custom)" })
		)
	end,
})

-- -- ========================================
-- LSP KEYMAPS (set when LSP attaches)
-- ========================================
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Information hover" }))
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
				{ "<leader>f", name = "Find" },
				{ "<leader>fd", name = "diagnostics" },
				{ "<leader>b", name = "Buffer" },
				{ "<leader>c", name = "Code chunk" },
				{ "<leader>g", name = "GitHub" },
				{ "<leader>l", name = "Lazygit" },
				{ "<leader>o", name = "Open REPL" },
				{ "<leader>q", name = "Close REPL" },
				{ "<leader>r", name = "R/Render" },
				{ "<leader>s", name = "Send/Sync" },
				{ "<leader>u", name = "UI toggle" },
			})
		end
	end,
})
