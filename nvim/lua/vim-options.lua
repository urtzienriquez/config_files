-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "ç"

-- Disable arrow keys in normal mode
vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true, silent = true })

-- Disable arrow keys in insert mode
vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true, silent = true })

-- Disable mouse
vim.opt.mouse = ""

-- misc options
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set tabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set softtabstop=2")
vim.cmd("set ignorecase") -- case insensitive search
vim.opt.clipboard = "unnamedplus"

-- code folding, automatic to manual
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Autocommands
local augroup_julia = vim.api.nvim_create_augroup("FileTypeJulia", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup_julia,
	pattern = "julia",
	callback = function(ev)
		vim.opt_local.textwidth = 92
		vim.opt_local.colorcolumn = "93"
	end,
})

-- Show diagnostics as virtual text (disabled by default since 0.11)
vim.diagnostic.config({ virtual_text = true })

-- Highlight without moving
vim.keymap.set("n", "*", "*``")

-- More natural split directions
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Auto-resize splits when terminal window changes size
-- (e.g. when splitting or zooming with tmux)
vim.api.nvim_create_autocmd({ "VimResized" }, { pattern = "*", command = "wincmd =" })
