vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})

require("which-key").setup({
  plugins = { spelling = { enabled = false } },
  delay = 0,
  preset = "helix",
  icons = { mappings = vim.g.have_nerd_font },
})

-- which-key groups
require("which-key").add({
  { "<leader>f", name = "Find" },
  { "<leader>fd", name = "diagnostics" },
  { "<leader>b", name = "Buffer" },
  { "<leader>c", name = "cd / code block" },
  { "<leader>o", name = "Open REPL" },
  { "<leader>q", name = "Close REPL" },
  { "<leader>r", name = "R / Render / Run" },
  { "<leader>s", name = "Send" },
  { "<leader>u", name = "UI toggle" },
  { "<leader>a", name = "Add" },
  { "<leader>g", name = "Git" },
})
