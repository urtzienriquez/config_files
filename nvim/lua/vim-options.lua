-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "ç"

-- vim options
vim.g.have_nerd_font = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.scrolloff = 10
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set softtabstop=2")
vim.opt.clipboard = "unnamedplus"

-- code folding, automatic to manual
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
