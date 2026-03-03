vim.b.completion = false

vim.schedule(function()
  local buf = vim.api.nvim_get_current_buf()
  local wk = require("which-key")

  local noop = function(mode, lhs)
    vim.keymap.set(mode, lhs, "<Nop>", { buffer = buf, silent = true })
  end

  noop("n", "<leader>rr")
  noop("n", "<leader><Enter>")
  noop("v", "<leader><Enter>")
  noop("n", "<leader><leader><Enter>")

  -- Hide from which-key in this buffer
  wk.add({
    { "<leader>rr", hidden = true, buffer = buf },
    { "<leader><CR>", hidden = true, buffer = buf },
    { "<leader><leader><CR>", hidden = true, buffer = buf },
  })
end)
