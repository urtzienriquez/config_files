-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- spelling language
vim.opt.spelllang = "en_us"
vim.opt.spell = true

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
vim.opt.scrolloff = 5
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- Display width of tab characters
vim.opt.shiftwidth = 2 -- Width for autoindent
vim.opt.softtabstop = 2 -- Number of spaces tab key inserts
vim.opt.smartindent = true -- Smart autoindenting (optional)
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- code folding, automatic to manual
vim.opt.foldcolumn = "1" -- '0' is not bad
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

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

-- Better line wrapping for text files
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
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true  -- Break at word boundaries
        vim.opt_local.showbreak = "↳ "  -- Visual indicator for wrapped lines
    end,
})
