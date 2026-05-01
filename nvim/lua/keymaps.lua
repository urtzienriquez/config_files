-- Arrow keys in normal mode → navigate quickfix
vim.keymap.set("n", "<Up>", "<cmd>cprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<cmd>cnext<CR>", { noremap = true, silent = true })

-- Escape terminal mode
vim.keymap.set("t", "<C-q><C-q>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Remap C-k to C-d to insert digraphs
vim.keymap.set("i", "<C-d>", "<C-k>", { noremap = true })

-- Resize windows
vim.keymap.set("n", "<M-Left>", ":vertical resize +5<CR>", { silent = true, desc = "Resize vertically +" })
vim.keymap.set("n", "<M-Right>", ":vertical resize -5<CR>", { silent = true, desc = "Resize vertically -" })
vim.keymap.set("n", "<M-Up>", ":resize +5<CR>", { silent = true, desc = "Resize horizontally +" })
vim.keymap.set("n", "<M-Down>", ":resize -5<CR>", { silent = true, desc = "Resize horizontally -" })

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
    vim.keymap.set("n", "<localleader><localleader><Enter>", "<CMD>silent update<BAR>source %<CR>", { desc = "exec lua file" })
    vim.keymap.set("n", "<localleader><Enter>", ":.lua<CR>", { desc = "exec lua line" })
    vim.keymap.set("v", "<localleader><Enter>", ":lua<CR>", { desc = "exec lua block" })
  end,
  desc = "Remove q-to-close in man pages",
})

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

-- cd to current buffers directory
vim.keymap.set('n', '<leader>~', function()
  local dir = vim.fn.expand('%:p:h')
  vim.api.nvim_set_current_dir(dir)
  print("CWD: " .. dir)
end, { desc = "CWD to buffer" })

-- go to help page of the text under the cursor with help!
vim.keymap.set("n", "vK", ":help!<CR>", { noremap = true, silent = true })

-- lsp
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "<leader>k", function()
      vim.diagnostic.open_float({ border = "single" })
    end, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  end,
})

-- love2d run
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

-- toggles
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    local function toggle(option, on_val, off_val)
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
    vim.keymap.set("n", "<leader>uS", toggle("spell", true, false), { desc = "Toggle Spelling" })
    vim.keymap.set("n", "<leader>us", function()
      if vim.bo.spelllang == "es_es" then
        vim.cmd("SpellEN")
      else
        vim.cmd("SpellES")
      end
    end, { desc = "Toggle Spell Language" })
    vim.keymap.set("n", "<leader>uw", toggle("wrap", true, false), { desc = "Toggle Wrap" })
    vim.keymap.set("n", "<leader>uo", toggle("scrolloff", 10, 0), { desc = "Toggle Scrolloff" })
    vim.keymap.set("n", "<leader>uc", toggle("cursorlineopt", "both", "number"), { desc = "Toggle Cursorline" })
    vim.keymap.set("n", "<leader>ul", toggle("relativenumber", true, false), { desc = "Toggle Relative Numbers" })
    vim.keymap.set("n", "<leader>uL", function()
      vim.wo.number = not vim.wo.number
      vim.o.relativenumber = vim.wo.number
      vim.notify("line numbers " .. (vim.wo.number and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle All Line Numbers" })
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
      vim.o.conceallevel = vim.o.conceallevel > 0 and 0 or 2
      vim.notify("Conceal " .. (vim.o.conceallevel > 0 and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle Conceal" })
    vim.keymap.set("n", "<leader>ud", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle Diagnostics" })
    vim.keymap.set("n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      vim.notify("Inlay hints " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
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
