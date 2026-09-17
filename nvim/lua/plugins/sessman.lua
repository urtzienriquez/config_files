vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/sessman.nvim") --[[@as string]])

require("sessman").setup({
  backend = "fzf",
})
