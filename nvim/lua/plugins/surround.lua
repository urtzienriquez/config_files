return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      move_cursor = false,
      surrounds = {
        ["c"] = {
          add = { "*", "*" },
          find = "%*.-%*",
          delete = "^(%*)(.-)(%*)$",
        },
        ["n"] = {
          add = { "**", "**" },
          find = "%*%*.-%*%*",
          delete = "^(%*%*)(.-)(%*%*)$",
        },
        ["g"] = {
          add = { "***", "***" },
          find = "%*%*%*.-%*%*%*",
          delete = "^(%*%*%*)(.-)(%*%*%*)$",
        },
        ["q"] = {
          add = { '"', '"' },
          find = '".-"',
          delete = '^(".)(.-)(")$',
        },
        ["s"] = {
          add = { "'", "'" },
        },
      },
    })
  end,
}
