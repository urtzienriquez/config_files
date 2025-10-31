-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- spelling language
vim.opt.spelllang = "en_us"
vim.opt.spell = true

-- Disable mouse
vim.opt.mouse = ""

-- misc options
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 5
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1"

-- for julia unicode symbols
vim.g.latex_to_unicode_auto = 1

-- code folding
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99 
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Show diagnostics as virtual text
vim.diagnostic.config({
	virtual_text = true,
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

-- More natural split directions
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Auto-resize splits when terminal window changes size
-- (e.g. when splitting or zooming with tmux)
vim.api.nvim_create_autocmd({ "VimResized" }, { pattern = "*", command = "wincmd =" })

-- Better line wrapping for text files
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"markdown",
		"text",
		"rmd",
		"Rmd",
		"jmd",
		"Jmd",
		"quarto",
		"qmd",
		"Qmd",
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
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.showbreak = "↳ "
	end,
})

-- Set pandoc syntax for markdown files to get LaTeX highlighting
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "rmd", "Rmd", "quarto", "qmd", "Qmd", "jmd", "Jmd" },
	callback = function()
		-- Delay to let R.nvim set its syntax first, then override
		vim.defer_fn(function()
			vim.cmd("set syntax=pandoc")
		end, 100)
	end,
})

-- Set rnoweb syntax for Rnw files to get LaTeX and R highlighting
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rnoweb" },
	callback = function()
		vim.defer_fn(function()
			vim.cmd("set syntax=rnoweb")
		end, 100)
	end,
})

-- -- Attach texlab to markdown-like files with LaTeX content
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "rmd", "Rmd", "quarto", "qmd", "Qmd", "jmd", "Jmd", "markdown" },
-- 	callback = function(args)
-- 		-- Only attach if file contains LaTeX commands
-- 		local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 100, false)
-- 		local has_latex = false
-- 		for _, line in ipairs(lines) do
-- 			if line:match("\\%w+") or line:match("%$%$") then
-- 				has_latex = true
-- 				break
-- 			end
-- 		end
--
-- 		if has_latex then
-- 			vim.lsp.start({
-- 				name = "texlab",
-- 				cmd = { "texlab" },
-- 				root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
-- 			})
-- 		end
-- 	end,
-- })

-- hack for apparently remaining in insert mode after selecting a file with Telescope
vim.api.nvim_create_autocmd("WinLeave", {
	callback = function()
		if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
		end
	end,
})
