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
vim.keymap.set("n", "*", "*``")

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
vim.keymap.set("n", "<leader><leader><Enter>", "<CMD>source %<CR>")
vim.keymap.set("n", "<leader><Enter>", ":.lua<CR>")
vim.keymap.set("v", "<leader><Enter>", ":lua<CR>")

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
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "single" })
    end, vim.tbl_extend("force", opts, { desc = "Information hover" }))

    vim.keymap.set("n", "<leader>k", function()
      vim.diagnostic.open_float({ border = "single" })
    end, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  end,
})

-- ========================================
-- PLUGIN-DEPENDENT KEYMAPS (after VeryLazy)
-- ========================================
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("plugin-keymaps", { clear = true }),
  pattern = "VeryLazy",
  callback = function()
    -- Oil file explorer
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

    -- Treesitter textobjects
    vim.keymap.set({ "x", "o" }, "af", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end, { desc = "Around function" })
    vim.keymap.set({ "x", "o" }, "if", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end, { desc = "Inside function" })
    vim.keymap.set({ "x", "o" }, "al", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
    end, { desc = "Around loop" })
    vim.keymap.set({ "x", "o" }, "il", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
    end, { desc = "Inside loop" })
    vim.keymap.set({ "x", "o" }, "ac", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
    end, { desc = "Around conditional" })
    vim.keymap.set({ "x", "o" }, "ic", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
    end, { desc = "Inside conditional" })

    -- ========================================
    -- UI Toggles
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

    vim.keymap.set("n", "<leader>uS", toggle_option("spell", true, false), { desc = "Toggle Spelling" })
    vim.keymap.set("n", "<leader>us", function()
      if vim.bo.spelllang == "es_es" then
        vim.cmd("SpellEN")
      else
        vim.cmd("SpellES")
      end
    end, { desc = "Toggle Spell Language" })

    vim.keymap.set("n", "<leader>uu", function()
      vim.cmd(":!lig")
    end, { silent = true, desc = "Toggle ligatures (ghostty)" })

    vim.keymap.set("n", "<leader>uw", toggle_option("wrap", true, false), { desc = "Toggle Wrap" })
    vim.keymap.set("n", "<leader>uo", toggle_option("scrolloff", 10, 0), { desc = "Toggle Scrolloff" })
    vim.keymap.set("n", "<leader>uc", toggle_option("cursorlineopt", "both", "number"), { desc = "Toggle Cursorline" })
    vim.keymap.set(
      "n",
      "<leader>ul",
      toggle_option("relativenumber", true, false),
      { desc = "Toggle Relative Numbers" }
    )

    vim.keymap.set("n", "<leader>uL", function()
      if vim.wo.number then
        vim.o.relativenumber = false
        vim.wo.number = false
        vim.notify("line numbers disabled", vim.log.levels.INFO)
      else
        vim.o.relativenumber = true
        vim.wo.number = true
        vim.notify("line numbers enabled", vim.log.levels.INFO)
      end
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

-- ========================================
-- WHICH-KEY GROUPS
-- ========================================
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("which-key-groups", { clear = true }),
  pattern = "VeryLazy",
  callback = function()
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then
      wk.add({
        { "<leader>f", name = "Find" },
        { "<leader>fd", name = "diagnostics" },
        { "<leader>b", name = "Buffer" },
        { "<leader>c", name = "cd/code block" },
        { "<leader>o", name = "Open REPL" },
        { "<leader>q", name = "Close REPL" },
        { "<leader>r", name = "R/Render" },
        { "<leader>s", name = "Send" },
        { "<leader>u", name = "UI toggle" },
        { "<leader>a", name = "Add" },
        { "<leader>g", name = "Git" },
      })
    end
  end,
})
