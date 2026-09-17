vim.pack.add({ "https://github.com/kylechui/nvim-surround" })

require("nvim-surround").setup({
  move_cursor = false,
  surrounds = {
    ["c"] = { add = { "*", "*" }, find = "%*.-%*", delete = "^(%*)(.-)(%*)$" },
    ["n"] = { add = { "**", "**" }, find = "%*%*.-%*%*", delete = "^(%*%*)(.-)(%*%*)$" },
    ["g"] = { add = { "***", "***" }, find = "%*%*%*.-%*%*%*", delete = "^(%*%*%*)(.-)(%*%*%*)$" },
    ["l"] = {
      add = function()
        local config = require("nvim-surround.config")
        local result = config.get_input("Enter LaTeX command: ")
        if result then
          return { { "\\" .. result .. "{" }, { "}" } }
        end
      end,
    },
  },
})

vim.g.nvim_surround_no_normal_mappings = true
vim.keymap.set("n", "s", "<Plug>(nvim-surround-normal)", { desc = "Add surround (motion)" })
vim.keymap.set("n", "ss", "<Plug>(nvim-surround-normal-cur)", { desc = "Add surround around line" })
vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)", { desc = "Change surround" })
