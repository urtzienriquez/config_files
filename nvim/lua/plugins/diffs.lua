vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" })

vim.g.diffs = {
  integrations = {
    fugitive = true,
    gitsigns = true,
  }
}
