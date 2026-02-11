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
		local fzf = require("fzf-lua")

		vim.keymap.set("n", "<leader>fp", fzf.builtin, { desc = "Find picker" })
		vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>f~", function()
			fzf.files({
				cwd = vim.fn.expand("~"),
				prompt = "Home files❯ ",
				hidden = true,
			})
		end, { desc = "Find files in home directory" })
		vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Find with grep" })
		vim.keymap.set("n", "<leader>fq", fzf.grep_quickfix, { desc = "Find inside the quickfix list with grep" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fB", fzf.git_branches, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Find help tags" })
		vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Find keymaps" })
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "Find current word" })
		vim.keymap.set("n", "<leader>fd", function()
			fzf.diagnostics_document()
		end, { desc = "Find diagnostics in current buffer" })
		vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Find diagnostics globally (workspace)" })
		vim.keymap.set("n", "<leader>fl", fzf.lsp_definitions, { desc = "Find LSP definitions" })
		vim.keymap.set("n", "<leader>fr", fzf.lsp_references, { desc = "Find LSP references" })
		vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Find LSP document symbols" })
		vim.keymap.set("n", "<leader>fS", function()
			fzf.lsp_document_symbols({ regex_filter = "Str.*" })
		end, { desc = "Find LSP symbols (strings/headers)" })
		vim.keymap.set("n", "<leader>ft", fzf.treesitter, { desc = "Find Treesitter symbols" })
		vim.keymap.set("n", "<leader>fm", fzf.spell_suggest, { desc = "Find spell suggestions" })
		vim.keymap.set("n", "<leader>f'", fzf.marks, { desc = "Find marks" })
		vim.keymap.set("n", "<leader>f,", fzf.resume, { desc = "Resume last picker" })
		vim.keymap.set("n", "<leader>f.", fzf.oldfiles, { desc = "Find recent files" })

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
			end, { desc = "Format buffer or range" })
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
		-- Buffer management
		-- ========================================
		vim.keymap.set("n", "<leader>bd", function()
			vim.cmd("bd")
		end, { desc = "Delete Buffer" })

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

		vim.keymap.set("n", "<leader>us", toggle_option("spell", true, false), { desc = "Toggle Spelling" })
		vim.keymap.set("n", "<leader>uw", toggle_option("wrap", true, false), { desc = "Toggle Wrap" })
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

		vim.keymap.set("n", "<leader>ub", toggle_option("background", "dark", "light"), { desc = "Toggle Background" })

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

-- ========================================
-- r.nvim
-- ========================================
local function set_rnvim_keymaps()
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>rf")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>gn")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>gN")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>ip")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>ka")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>kn")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>d")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>rd")
	pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<leader>aa")

	local opts_keymap = { noremap = true, silent = true, buffer = true }

	vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts_keymap)
	vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts_keymap)

	vim.keymap.set("n", "<leader>or", "<Plug>RStart", opts_keymap)
	vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", opts_keymap)
	vim.keymap.set("n", "<leader>qr", "<Plug>RClose", opts_keymap)
	vim.keymap.set("n", "<leader>cn", "<Plug>RNextRChunk", opts_keymap)
	vim.keymap.set("n", "<leader>cN", "<Plug>RPreviousRChunk", opts_keymap)
	vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", opts_keymap)

	-- Render bookdown book
	vim.keymap.set("n", "<leader>rb", function()
		local file = vim.fn.expand("%:t")
		file = file:gsub('"', '\\"') -- escape any double quotes in filename
		local rcmd = string.format(
			'out <- tryCatch(bookdown::render_book("%s"), error=function(e){'
				.. 'message("BOOKDOWN RENDER ERROR: ", e$message); NULL });'
				.. "if(!is.null(out)){ if(is.list(out)) out <- unlist(out)[1];"
				.. "if(length(out) >= 1 && file.exists(out[1])){ out <- "
				.. 'normalizePath(out[1]); system2("xdg-open", out);'
				.. 'message("Opened: ", out) } else message("Render completed'
				.. 'but output file not found: ", paste(out, collapse=", ")) }',
			file
		)
		vim.cmd("RSend " .. rcmd)
	end, { noremap = true, silent = true, desc = "Render and open Bookdown" })

	-- Render markdown with output name
	-- none entered: filename, else: provided name, esc: cancel
	vim.keymap.set("n", "<leader>rr", function()
		local filename = vim.fn.input({
			prompt = "Output filename (without extension): ",
			cancelreturn = "__CANCEL__",
		})
		vim.api.nvim_echo({}, false, {})
		if filename == "__CANCEL__" then
			return
		end

		-- Clear params if it exists
		vim.cmd('RSend if(exists("params")) rm(params)')

		if filename ~= "" then
			vim.cmd('RSend rmarkdown::render("' .. vim.fn.expand("%") .. '", output_file = "' .. filename .. '")')
		else
			vim.cmd('RSend rmarkdown::render("' .. vim.fn.expand("%") .. '")')
		end
	end, { desc = "Render R Markdown with custom output name" })

	-- add inline r code in insert and normal modes
	vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", opts_keymap)
	vim.keymap.set(
		"n",
		"<leader>ac",
		"i`r<Space>`<Esc>i",
		vim.tbl_extend("force", opts_keymap, { desc = "Add inline code" })
	)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "r", "rmd", "Rmd", "rnoweb" },
	callback = function()
		set_rnvim_keymaps()
	end,
})

-- ========================================
-- vim-slime keymaps
-- ========================================
local slime_utils = require("core.slime_utils")

local function set_slime_keymaps()
	local opts_keymap = { noremap = true, silent = true, buffer = true }
	local repl_utils = require("core.repl_utils")
	local has_smart_blocks = repl_utils.has_smart_blocks()

	-- Start REPLs
	vim.keymap.set("n", "<leader>op", function()
		slime_utils.start_tmux_repl("python")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start Python REPL" }))

	vim.keymap.set("n", "<leader>oj", function()
		slime_utils.start_tmux_repl_with_version("julia")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start Julia REPL" }))

	vim.keymap.set("n", "<leader>om", function()
		slime_utils.start_tmux_repl("matlab")
	end, vim.tbl_extend("force", opts_keymap, { desc = "Start MATLAB REPL" }))

	-- Send code - smart block detection for Julia/Python, paragraph for others
	if has_smart_blocks then
		-- Smart block sending (Julia/Python)
		vim.keymap.set("n", "<Return>", function()
			if slime_utils.has_active_repl() then
				local text, _, end_line = repl_utils.get_send_text()
				if text then
					vim.fn["slime#send"](text .. "\n")
					-- Move cursor to line after the block, or stay on last line if at end of buffer
					local total_lines = vim.api.nvim_buf_line_count(0)
					local next_line = math.min(end_line + 1, total_lines)
					vim.api.nvim_win_set_cursor(0, { next_line, 0 })

					-- If we're not at the last line, skip following empty lines
					if next_line < total_lines then
						local lines = vim.api.nvim_buf_get_lines(0, next_line - 1, total_lines, false)
						local skip_count = 0
						for _, line in ipairs(lines) do
							if line:match("^%s*$") then
								skip_count = skip_count + 1
							else
								break
							end
						end
						if skip_count > 0 then
							vim.api.nvim_win_set_cursor(0, { math.min(next_line + skip_count, total_lines), 0 })
						end
					end
				end
			else
				vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
			end
		end, vim.tbl_extend("force", opts_keymap, { desc = "Send block to REPL" }))

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
		end, vim.tbl_extend("force", opts_keymap, { desc = "Send selection to REPL" }))
	else
		-- Paragraph-based sending (MATLAB, etc.)
		vim.keymap.set("n", "<Return>", function()
			if slime_utils.has_active_repl() then
				local keys = "vap"
					.. vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, false, true)
					.. "'>j"
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
	end

	-- Send entire buffer
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
			local keys = 'using Pkg; Pkg.activate(".")\nPkg.instantiate()\n'
			vim.fn["slime#send"](keys)
		else
			vim.notify("No active REPL. Start one with <leader>oj", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Activate and instantiate Julia project" }))

	-- Change working directory
	vim.keymap.set("n", "<leader>cd", function()
		if slime_utils.has_active_repl() then
			slime_utils.sync_working_directory()
		else
			vim.notify("No active REPL. Start one with <leader>op/oj/om", vim.log.levels.WARN)
		end
	end, vim.tbl_extend("force", opts_keymap, { desc = "Change working directory to cwd in REPL" }))

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

	-- Debug block detection (unified for all languages with smart blocks)
	if has_smart_blocks then
		vim.keymap.set("n", "<leader>bc", function()
			repl_utils.debug_block_detection()
		end, vim.tbl_extend("force", opts_keymap, { desc = "Debug block detection" }))
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "julia", "matlab" },
	callback = function()
		set_slime_keymaps()
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
			set_rnvim_keymaps()
		elseif lang == "python" or lang == "julia" or lang == "matlab" then
			set_slime_keymaps()
		end
	end,
})

-- ========================================
-- Citation Picker
-- ========================================
local citation = require("core.citation-picker")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "rmd", "Rmd", "quarto", "jmd", "Jmd", "tex", "pandoc" },
	callback = function()
		local opts = { buffer = true, silent = true }
		-- Markdown format (@key)
		vim.keymap.set(
			"i",
			"<C-a>m",
			citation.citation_picker_markdown,
			vim.tbl_extend("force", opts, { desc = "Add citations (markdown)" })
		)
		-- LaTeX format (\cite{key})
		vim.keymap.set(
			"i",
			"<C-a>l",
			citation.citation_picker_latex,
			vim.tbl_extend("force", opts, { desc = "Add citations (latex)" })
		)
		vim.keymap.set(
			"n",
			"<leader>am",
			citation.citation_picker_markdown,
			vim.tbl_extend("force", opts, { desc = "Add citations (markdown)" })
		)
		vim.keymap.set(
			"n",
			"<leader>al",
			citation.citation_picker_latex,
			vim.tbl_extend("force", opts, { desc = "Add citations (latex)" })
		)
		vim.keymap.set(
			"n",
			"<leader>ar",
			citation.citation_replace,
			vim.tbl_extend("force", opts, { desc = "Add replacement citation under cursor" })
		)
	end,
})

-- ========================================
-- Cross-reference Picker
-- ========================================
local crossref = require("core.crossref-picker")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "rmd", "Rmd", "quarto" },
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set(
			"i",
			"<C-a>f",
			crossref.figure_picker,
			vim.tbl_extend("force", opts, { desc = "Add figure crossref" })
		)
		vim.keymap.set(
			"n",
			"<leader>af",
			crossref.figure_picker,
			vim.tbl_extend("force", opts, { desc = "Add figure crossref" })
		)
		vim.keymap.set(
			"i",
			"<C-a>t",
			crossref.table_picker,
			vim.tbl_extend("force", opts, { desc = "Add table crossref" })
		)
		vim.keymap.set(
			"n",
			"<leader>at",
			crossref.table_picker,
			vim.tbl_extend("force", opts, { desc = "Add table crossref" })
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
				{ "<leader>a", name = "Add citation/crossref" },
				{ "<leader>ug", name = "git toggle" },
			})
		end
	end,
})
