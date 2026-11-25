-- mini.clue: citeref group (only for TeX files)
vim.b.miniclue_config = {
  clues = {
    { mode = "n", keys = "<Leader>a", desc = "(Add citation)" },
    { mode = "n", keys = "<Leader>r", desc = "(Manuscript: build, Word, submit)" },
  },
}
