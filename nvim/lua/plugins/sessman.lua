vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/sessman.nvim") --[[@as string]])

require("sessman").setup({
  backend = "fzf",
})

vim.keymap.set("n", "<leader>ms", "<Cmd>SessionLoad<CR>", {desc = "session manager"})
vim.keymap.set("n", "<leader>mw", "<Cmd>SessionSaveCurrent<CR>", {desc = "save session"})
