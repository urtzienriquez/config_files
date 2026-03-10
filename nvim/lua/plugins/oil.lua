vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
  default_file_explorer = true,
  use_default_keymaps = true,
  view_options = { show_hidden = true },
  keymaps = {
    ["t"] = { "actions.parent", mode = "n" },
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
    ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
    ["<leader>l"] = "actions.refresh",
  },
})

vim.keymap.set("n", "<leader>t", function()
  local oil = require("oil")
  if vim.bo.filetype == "oil" then
    oil.close()
  else
    oil.open()
  end
end, { desc = "Toggle Oil file explorer" })
