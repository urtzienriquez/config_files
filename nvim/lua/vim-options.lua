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
