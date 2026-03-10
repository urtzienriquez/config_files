vim.pack.add({ "https://github.com/kylechui/nvim-surround" })

vim.cmd.packadd("nvim-surround")
require("nvim-surround").setup({
  move_cursor = false,
  surrounds = {
    ["c"] = { add = { "*", "*" }, find = "%*.-%*", delete = "^(%*)(.-)(%*)$" },
    ["n"] = { add = { "**", "**" }, find = "%*%*.-%*%*", delete = "^(%*%*)(.-)(%*%*)$" },
    ["g"] = { add = { "***", "***" }, find = "%*%*%*.-%*%*%*", delete = "^(%*%*%*)(.-)(%*%*%*)$" },
    ["q"] = {
      add = { "\u{201C}", "\u{201D}" },
      find = "\u{201C}.-\u{201D}",
      delete = "^(\u{201C})(.-)(\\u{201D})$",
    },
    ["s"] = { add = { "'", "'" } },
  },
})
