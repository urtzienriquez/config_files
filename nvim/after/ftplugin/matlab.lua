-- mini.clue: replent REPL groups (only for MATLAB files)
vim.b.miniclue_config = {
  clues = {
    { mode = "n", keys = "<Leader>o", desc = "(Open REPL)" },
    { mode = "n", keys = "<Leader>q", desc = "(Close REPL)" },
    { mode = "n", keys = "<Leader>s", desc = "(Send)" },
    { mode = "n", keys = "<Leader>c", desc = "(cd)" },
  },
}
