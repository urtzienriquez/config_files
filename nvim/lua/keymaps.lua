-- Basic keymaps
-- ===============

-- Disable arrow keys in insert mode
vim.keymap.set("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<Right>", "<Nop>", { noremap = true, silent = true })

-- Arrow keys in normal mode → navigate quickfix
vim.keymap.set("n", "<Up>", "<cmd>cprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<cmd>cnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<cmd>cclose<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<cmd>copen<CR>", { noremap = true, silent = true })

-- Highlight without moving
vim.keymap.set("n", "*", function()
  local word = vim.fn.expand("<cword>")
  vim.fn.setreg("/", word)
  vim.opt.hlsearch = true
end, { noremap = true, desc = "Search word under cursor, stay in place" })

-- Escape terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Remap C-k to C-d to insert digraphs
vim.keymap.set("i", "<C-d>", "<C-k>", { noremap = true })

-- Resize windows
vim.keymap.set("n", "<C-A-Left>", ":vertical resize +5<CR>", { silent = true, desc = "Resize vertically +" })
vim.keymap.set("n", "<C-A-Right>", ":vertical resize -5<CR>", { silent = true, desc = "Resize vertically -" })
vim.keymap.set("n", "<C-A-Up>", ":resize +5<CR>", { silent = true, desc = "Resize horizontally +" })
vim.keymap.set("n", "<C-A-Down>", ":resize -5<CR>", { silent = true, desc = "Resize horizontally -" })

-- Half page up/down, keeping cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Jump half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Jump half page up" })

-- Clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better paste: don't overwrite register in visual mode
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

-- Search: center results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Execute Lua
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lua-keymaps", { clear = true }),
  pattern = "lua",
  callback = function()
    vim.keymap.set("n", "<leader><leader><Enter>", "<CMD>silent update<BAR>source %<CR>", { desc = "exec lua file" })
    vim.keymap.set("n", "<leader><Enter>", ":.lua<CR>", { desc = "exec lua line" })
    vim.keymap.set("v", "<leader><Enter>", ":lua<CR>", { desc = "exec lua block" })
  end,
  desc = "Remove q-to-close in man pages",
})

-- Refresh git status
vim.keymap.set("n", "<leader>gg", ":GitStatusRefresh<CR>", { silent = true, desc = "Refresh git status" })

-- Add all case variants of a word to spellfile
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

-- ========================================
-- LSP KEYMAPS (set on LspAttach)
-- ========================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "<leader>k", function()
      vim.diagnostic.open_float({ border = "single" })
    end, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  end,
})

-- ========================================
-- love2d run
-- ========================================
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("love2d-maps", { clear = true }),
  pattern = "*.lua",
  callback = function()
    local root = vim.fs.root(0, { "main.lua" })
    if not root then
      return
    end
    vim.keymap.set("n", "<leader>rr", function()
      vim.cmd("write")
      vim.fn.jobstart({ "love", root }, { detach = true })
    end, { buffer = true, desc = "Run Love2D game" })
  end,
})
