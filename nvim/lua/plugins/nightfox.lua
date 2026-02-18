return {
	"EdenEast/nightfox.nvim",
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
					-- SignColumn = { bg = "none" },
					WinSeparator = { fg = "palette.blue.base", bg = "none" },
				},
			},
		})
		vim.cmd.colorscheme("nightfox")
	end,
}
