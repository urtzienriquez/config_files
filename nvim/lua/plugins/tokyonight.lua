return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			on_colors = function(colors)
				colors.border = colors.blue2 -- change border color
			end,
			on_highlights = function(hl, c)
				hl.FloatBorder = { fg = c.blue2 }
				hl.Pmenu = { fg = c.blue2 }
			end,
			style = "moon",
		})
		vim.cmd.colorscheme("tokyonight-moon")
	end,
}

