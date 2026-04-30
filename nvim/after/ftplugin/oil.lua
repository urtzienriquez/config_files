vim.b.completion = false

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("oil-clues", { clear = true }),
  pattern = "oil",
  callback = function()
    require("mini.clue").ensure_buf_triggers()
  end,
})
