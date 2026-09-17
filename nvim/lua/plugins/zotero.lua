vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/zotero.nvim") --[[@as string]])

require("zotero").setup({
  backend = "fzf",
  max_items = "3000",
})
