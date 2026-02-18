return {
	"urtzienriquez/nightfox.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("nightfox").setup({
			options = {
				styles = {
					comments = "italic",
					keywords = "bold",
				},
			},
			groups = {
				all = {
					-- Use 'spec.' prefix to access your background/foreground variables
					NormalNC = { fg = "spec.fg1", bg = "spec.bg1" },

					-- Use 'palette.' to access raw colors defined in your palette
					WinSeparator = { fg = "palette.blue.base", bg = "none" },

					-- Use 'spec.syntax' for specific syntax colors
					-- ["@markup.strong"] = { fg = "spec.syntax.keyword", style = "bold" },
					["@markup.strong"] = { style = "bold" },
				},
			},
		})
		vim.cmd.colorscheme("nightfox")
	end,
}
