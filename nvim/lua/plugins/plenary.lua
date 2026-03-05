return {
  "nvim-lua/plenary.nvim",
  init = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = "*_spec.lua",
      callback = function(event)
        require("plenary")
        vim.keymap.set("n", "<leader>rt", function()
          vim.cmd("PlenaryBustedFile %")
        end, {
          buffer = event.buf,
          desc = "run tests plenary",
        })
      end,
    })
  end,
}
