return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      on_colors = function(colors)
        colors.border = colors.blue2 -- change border color
      end,
      style = "night",
    })
    vim.cmd.colorscheme("tokyonight-night")
  end,
}

