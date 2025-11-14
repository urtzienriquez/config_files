-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- spelling language
vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- Disable mouse
vim.opt.mouse = ""

-- misc options
vim.g.have_nerd_font = true
vim.opt.cursorline = true
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
function _G.custom_foldtext()
	local start_line = vim.fn.getline(vim.v.foldstart)
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	start_line = start_line:gsub("%s*$", "")
	if #start_line > 80 then
		start_line = start_line:sub(1, 80) .. "..."
	end
	return string.format("%s  ···%d lines", start_line, line_count)
end
vim.opt.foldtext = "v:lua.custom_foldtext()"

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
		vim.defer_fn(function()
			vim.cmd("set syntax=pandoc")
		end, 100)
	end,
})

-- Ensure netrw syntax
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "netrw" },
	callback = function()
		vim.defer_fn(function()
			vim.cmd("set syntax=netrw")
		end, 100)
	end,
})

-- hack for apparently remaining in insert mode after selecting a file with Telescope
vim.api.nvim_create_autocmd("WinLeave", {
	callback = function()
		if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
		end
	end,
})
