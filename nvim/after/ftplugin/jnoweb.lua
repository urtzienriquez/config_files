-- mini.clue: replent REPL (Julia) + manuscript + citeref (only for jnoweb files)
vim.b.miniclue_config = {
  clues = {
    { mode = "n", keys = "<Leader>o", desc = "(Open REPL)" },
    { mode = "n", keys = "<Leader>q", desc = "(Close REPL)" },
    { mode = "n", keys = "<Leader>s", desc = "(Send)" },
    { mode = "n", keys = "<Leader>c", desc = "(cd/code)" },
    { mode = "n", keys = "<Leader>r", desc = "(Manuscript: build, Word, submit)" },
    { mode = "n", keys = "<Leader>a", desc = "(Add citation)" },
  },
}

-- (chunks: painted by nightfox, as in Rnoweb and R Markdown)

-- inline code, as \Sexpr{} in Rnoweb
vim.keymap.set("i", "<C-a>c", "\\Sexpr{}<Left>", { buffer = true, desc = "Add inline Julia code" })
vim.keymap.set("n", "<leader>cc", "i\\Sexpr{}<Left>", { buffer = true, desc = "Add inline Julia code" })

require("julia_latex").setup(0)
