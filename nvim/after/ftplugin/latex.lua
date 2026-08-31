-- mini.clue: citeref group (only for LaTeX files)
vim.b.miniclue_config = {
  clues = {
    { mode = "n", keys = "<Leader>a", desc = "(Add citation)" },
    { mode = "n", keys = "<Leader>l", desc = "(LaTeX)" },
  },
}
