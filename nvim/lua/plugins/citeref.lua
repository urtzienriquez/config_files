vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/citeref.nvim") --[[@as string]])

require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
  default_latex_format = "parencite",
  picker = { rnoweb_labels = "tex_only" },
})
