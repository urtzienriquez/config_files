-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "-"

-- vim options
vim.g.have_nerd_font = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.scrolloff = 10
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set softtabstop=2")
vim.opt.clipboard = "unnamed"

-- code folding, automatic to manual
vim.opt.foldlevelstart = 99

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
