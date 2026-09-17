vim.pack.add({ "https://github.com/nvim-mini/mini.statusline" })

local statusline = require("mini.statusline")

local contents = function()
  local mode, mode_hl = statusline.section_mode({ trunc_width = 50 })
  local git = statusline.section_git({ trunc_width = 40 })
  local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
  local lsp = statusline.section_lsp({ trunc_width = 75 })
  local filename = statusline.section_filename({ trunc_width = 100 })
  local location = "%l,%2v"
  local search = statusline.section_searchcount({ trunc_width = 75 })

  return statusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics, lsp } },
    "%<",
    { hl = "MiniStatuslineFilename", strings = { filename } },
    "%=",
    { hl = "MiniStatuslineFileinfo", strings = { vim.bo.filetype } },
    { hl = mode_hl, strings = { search, location } },
  })
end

statusline.setup({
  content = { active = contents },
})
