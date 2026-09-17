vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup({
  current_line_blame = true,

  on_attach = function(bufnr)
    local gs = require("gitsigns")

    -- Navigation
    vim.keymap.set("n", "]g", function()
      if vim.wo.diff then
        return "]g"
      end
      vim.schedule(function()
        gs.nav_hunk("next")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Next hunk" })

    vim.keymap.set("n", "[g", function()
      if vim.wo.diff then
        return "[g"
      end
      vim.schedule(function()
        gs.nav_hunk("prev")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Prev hunk" })

    vim.keymap.set("n", "<leader>gS", gs.preview_hunk, { buffer = bufnr, desc = "Git diff (hunk)" })
    vim.keymap.set("n", "<leader>gR", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
    vim.keymap.set("v", "<leader>gR", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "Reset selection" })
  end,
})
