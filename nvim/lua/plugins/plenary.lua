local gh = require("plugins.utils").gh

vim.pack.add({ gh("nvim-lua/plenary.nvim") })

vim.cmd.packadd("plenary.nvim")

-- plenary test runner
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = "*_spec.lua",
  callback = function(ev)
    vim.keymap.set("n", "<leader>rt", function()
      local prev = vim.o.winborder
      vim.o.winborder = "none"
      vim.cmd("PlenaryBustedFile %")
      vim.o.winborder = prev
    end, { buffer = ev.buf, desc = "Run tests (plenary)" })
  end,
})
