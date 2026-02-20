-- =========
-- KEYMAPS
-- =========

-- Basic keymaps
-- ===============

-- Disable arrow keys in insert mode
vim.keymap.set("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Right>", "<Nop>", { noremap = true, silent = true })
-- arrows in normal mode to navigate quickfix
vim.keymap.set("n", "<Up>", "<cmd>cprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<cmd>cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<cmd>cclose<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<cmd>copen<CR>", { noremap = true, silent = true })

-- Highlight without moving
vim.keymap.set("n", "*", "*``")

-- Escape terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- remap C-k to C-d to insert digraphs
vim.keymap.set("i", "<C-d>", "<C-k>", { noremap = true })

-- Resize windows
vim.keymap.set("n", "<C-A-Left>", ":vertical resize +5<CR>", { silent = true, desc = "Resize vertically" })
vim.keymap.set("n", "<C-A-Right>", ":vertical resize -5<CR>", { silent = true, desc = "Resize vertically" })
vim.keymap.set("n", "<C-A-Up>", ":resize +5<CR>", { silent = true, desc = "Resize horizontally" })
vim.keymap.set("n", "<C-A-Down>", ":resize -5<CR>", { silent = true, desc = "Resize horizontally" })

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

-- Better search centering and n/N behavior
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Better Y behavior (yank to end of line like C and D)
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Highlight when yanking text
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
		"jmd",
		"qmd",
		"org",
		"rst",
		"asciidoc",
		"adoc",
		"tex",
		"latex",
		"wiki",
		"textile",
		"mail",
		"gitcommit",
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
		vim.cmd("silent spellgood " .. v)
	end
	vim.notify("Added variants of '" .. word .. "' to spellfile", vim.log.levels.INFO)
end, {})

vim.keymap.set("n", "zg", ":ZgVariants<CR>", { noremap = true, silent = true })

-- refresh git status
vim.keymap.set("n", "<leader>gg", ":GitStatusRefresh<CR>", { silent = true, desc = "refresh git status" })

-- show notification history
vim.keymap.set("n", "<leader>n", function()
	local result = vim.api.nvim_exec2("messages", { output = true })
	local lines = vim.split(result.output, "\n")
	local buf = vim.api.nvim_create_buf(false, true) -- (listed=false, scratch=true)

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = (vim.o.lines - height) * 0.5,
		col = (vim.o.columns - width) * 0.5,
		style = "minimal",
		border = "rounded",
		title = " Notification history ",
		title_pos = "center",
		footer = " q to quit ",
	}

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })

	vim.api.nvim_open_win(buf, true, opts)
end, { noremap = true, silent = true, desc = "show notification history" })

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
		-- fzf-lua (fuzzy finding) keymaps
		-- ========================================
		vim.keymap.set("n", "<leader>fp", function()
			require("fzf-lua").builtin()
		end, { desc = "Find picker" })
		vim.keymap.set("n", "<leader>ff", function()
			require("fzf-lua").files()
		end, { desc = "Find files" })
		vim.keymap.set("n", "<leader>f~", function()
			require("fzf-lua").files({
				cwd = vim.fn.expand("~"),
				prompt = "Home files❯ ",
				hidden = true,
			})
		end, { desc = "Find files in home directory" })
		vim.keymap.set("n", "<leader>fg", function()
			require("fzf-lua").live_grep()
		end, { desc = "Find with grep" })
		vim.keymap.set("n", "<leader>fq", function()
			require("fzf-lua").grep_quickfix()
		end, { desc = "Find inside the quickfix list with grep" })
		vim.keymap.set("n", "<leader>fb", function()
			require("fzf-lua").buffers()
		end, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fh", function()
			require("fzf-lua").help_tags()
		end, { desc = "Find help tags" })
		vim.keymap.set("n", "<leader>fk", function()
			require("fzf-lua").keymaps()
		end, { desc = "Find keymaps" })
		vim.keymap.set("n", "<leader>fw", function()
			require("fzf-lua").grep_cword()
		end, { desc = "Find current word" })
		vim.keymap.set("n", "<leader>fd", function()
			require("fzf-lua").diagnostics_document()
		end, { desc = "Find diagnostics in current buffer" })
		vim.keymap.set("n", "<leader>fD", function()
			require("fzf-lua").diagnostics_workspace()
		end, { desc = "Find diagnostics globally (workspace)" })
		vim.keymap.set("n", "<leader>fl", function()
			require("fzf-lua").lsp_definitions()
		end, { desc = "Find LSP definitions" })
		vim.keymap.set("n", "<leader>fr", function()
			require("fzf-lua").lsp_references()
		end, { desc = "Find LSP references" })
		vim.keymap.set("n", "<leader>fs", function()
			require("fzf-lua").lsp_document_symbols()
		end, { desc = "Find LSP document symbols" })
		vim.keymap.set("n", "<leader>fS", function()
			require("fzf-lua").lsp_document_symbols({ regex_filter = "Str.*" })
		end, { desc = "Find LSP symbols (strings/headers)" })
		vim.keymap.set("n", "<leader>ft", function()
			require("fzf-lua").treesitter()
		end, { desc = "Find Treesitter symbols" })
		vim.keymap.set("n", "<leader>fm", function()
			require("fzf-lua").spell_suggest()
		end, { desc = "Find spell suggestions" })
		vim.keymap.set("n", "<leader>f'", function()
			require("fzf-lua").marks()
		end, { desc = "Find marks" })
		vim.keymap.set("n", "<leader>f,", function()
			require("fzf-lua").resume()
		end, { desc = "Resume last picker" })
		vim.keymap.set("n", "<leader>f.", function()
			require("fzf-lua").oldfiles()
		end, { desc = "Find recent files" })
		-- git related
		vim.keymap.set("n", "<leader>gb", function()
			require("fzf-lua").git_branches()
		end, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>gC", function()
			require("fzf-lua").git_commits()
		end, { desc = "Find git commits" })

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
		-- Toggles
		-- ========================================
		local function toggle_option(option, on_val, off_val)
			return function()
				if vim.o[option] == off_val then
					vim.o[option] = on_val
					vim.notify(option .. " enabled", vim.log.levels.INFO)
				else
					vim.o[option] = off_val
					vim.notify(option .. " disabled", vim.log.levels.INFO)
				end
			end
		end

		vim.keymap.set("n", "<leader>uS", toggle_option("spell", true, false), { desc = "Toggle Spelling" })
		vim.keymap.set("n", "<leader>us", function()
			local current = vim.bo.spelllang
			if current == "es_es" then
				vim.cmd("SpellEN")
			else
				vim.cmd("SpellES")
			end
		end, { desc = "Toggle Spell Language" })

		vim.keymap.set("n", "<leader>uw", toggle_option("wrap", true, false), { desc = "Toggle Wrap" })
		vim.keymap.set("n", "<leader>uo", toggle_option("scrolloff", 10, 0), { desc = "Toggle Scrolloff" })

		vim.keymap.set(
			"n",
			"<leader>uc",
			toggle_option("cursorlineopt", "both", "number"),
			{ desc = "Toggle Cursorline" }
		)

		vim.keymap.set(
			"n",
			"<leader>ul",
			toggle_option("relativenumber", true, false),
			{ desc = "Toggle Line Numbers" }
		)
		local function toggle_line_numbers()
			if vim.wo.number == true then
				vim.o.relativenumber = false
				vim.wo.number = false
				vim.notify("line numbers disabled", vim.log.levels.INFO)
			else
				vim.o.relativenumber = true
				vim.wo.number = true
				vim.notify("line numbers enabled", vim.log.levels.INFO)
			end
		end
		vim.keymap.set("n", "<leader>uL", toggle_line_numbers, { desc = "Toggle All Line Numbers" })

		vim.keymap.set("n", "<leader>ub", function()
			if vim.o.background == "dark" then
				vim.cmd.colorscheme("dayfox")
				vim.notify("colorscheme = dayfox", vim.log.levels.INFO)
			else
				vim.cmd.colorscheme("nightfox")
				vim.notify("colorscheme = nightfox", vim.log.levels.INFO)
			end
		end, { desc = "Toggle Background" })

		vim.keymap.set("n", "<leader>ux", function()
			if vim.o.conceallevel > 0 then
				vim.o.conceallevel = 0
				vim.notify("Conceal disabled", vim.log.levels.INFO)
			else
				vim.o.conceallevel = 2
				vim.notify("Conceal enabled", vim.log.levels.INFO)
			end
		end, { desc = "Toggle Conceal" })

		vim.keymap.set("n", "<leader>ud", function()
			vim.diagnostic.enable(not vim.diagnostic.is_enabled())
			vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
		end, { desc = "Toggle Diagnostics" })

		vim.keymap.set("n", "<leader>uh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			vim.notify(
				"Inlay hints " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"),
				vim.log.levels.INFO
			)
		end, { desc = "Toggle Inlay Hints" })

		vim.keymap.set("n", "<leader>uT", function()
			local buf = vim.api.nvim_get_current_buf()
			if vim.treesitter.highlighter.active[buf] then
				vim.treesitter.stop(buf)
				vim.notify("Treesitter disabled", vim.log.levels.INFO)
			else
				vim.treesitter.start(buf)
				vim.notify("Treesitter enabled", vim.log.levels.INFO)
			end
		end, { desc = "Toggle Treesitter" })
	end,
})

-- -- ========================================
-- LSP KEYMAPS (set when LSP attaches)
-- ========================================
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "single" })
		end, vim.tbl_extend("force", opts, { desc = "Information hover" }))

		vim.keymap.set("n", "<leader>k", function()
			vim.diagnostic.open_float({ border = "single" })
		end, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
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
				{ "<leader>c", name = "cd/code block" },
				{ "<leader>o", name = "Open REPL" },
				{ "<leader>q", name = "Close REPL" },
				{ "<leader>r", name = "R/Render" },
				{ "<leader>s", name = "Send" },
				{ "<leader>u", name = "UI toggle" },
				{ "<leader>a", name = "Add" },
				{ "<leader>g", name = "Git" },
			})
		end
	end,
})
