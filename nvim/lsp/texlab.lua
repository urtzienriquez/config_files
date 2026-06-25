return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/texlab" },
  filetypes = { "tex", "plaintex", "bib", "rnoweb", "jnoweb" },
  root_markers = { ".latexmkrc", ".texlabroot", ".git" },

  -- This part tells Neovim: "Don't use this LSP for formatting"
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,

  settings = {
    texlab = {
      -- 1. Disable the internal build system entirely if you don't want save triggers
      build = {
        onSave = false,
      },
      -- 2. Disable linting/chktex if you want it even quieter
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
      -- 3. Specifically disable the built-in formatting engines
      formatter = "none",
      bibtexFormatter = "none",

      -- Everything else (hover, completion, definitions) stays on by default
      diagnostics = {
        ignoredPatterns = { "Duplicate label", "Unused label", "Unknown language" },
      },
    },
  },
}
