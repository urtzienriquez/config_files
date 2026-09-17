vim.pack.add({
  "https://github.com/justinmk/vim-dirvish",
  "https://github.com/brianhuster/dirvish-do.nvim",
})

vim.g.dirvish_mode = ":sort | sort ,^.*[\\/],"

require("dirvish-do").setup({
  keymaps = {
    remove = "dd",
  },
})
