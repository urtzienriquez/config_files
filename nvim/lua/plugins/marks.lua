return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {
    -- Disable line number highlighting
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    excluded_filetypes = {},
    excluded_buftypes = { "nofile" },
    builtin_marks = { ".", "<", ">", "^" },
    cyclic = true,
    force_write_shada = false,
    refresh_interval = 250,
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    bookmark_0 = {
      sign = "⚑",
      virt_text = "hello world",
      annotate = false,
    },
    mappings = {}
  },
  config = function(_, opts)
    require("marks").setup(opts)
    
    -- Override highlight groups to prevent line number color changes
    -- vim.api.nvim_set_hl(0, "MarkSignHL", { link = "Normal" })
    vim.api.nvim_set_hl(0, "MarkSignNumHL", { link = "LineNr" })
    vim.api.nvim_set_hl(0, "MarkVirtTextHL", { link = "Comment" })
    
  end,
}
