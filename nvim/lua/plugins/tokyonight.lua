return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			on_colors = function(colors)
				colors.border = colors.blue2
				colors.comment = colors.dark5
			end,
			on_highlights = function(hl, c)
				hl.FloatBorder = { fg = c.blue2 }
				hl.Pmenu = { fg = c.blue2 }
				hl.LineNrAbove = { fg = c.dark5 }
				hl.LineNrBelow = { fg = c.dark5 }
				hl.DiagnosticUnnecessary = { fg = c.dark5, italic = true }
				hl.StatusLine = { fg = c.dark5, bg = c.bg_dark1 }
				hl.NormalNC = { bg = c.bg_dark1 }
				hl.SignColumn = { bg = "none" }
			end,
			style = "moon",
		})
		vim.cmd.colorscheme("tokyonight-moon")
	end,
}
