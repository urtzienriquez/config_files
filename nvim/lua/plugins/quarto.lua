return {
	"quarto-dev/quarto-nvim",
	dependencies = {
		"jmbuhr/otter.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	ft = { "quarto", "markdown" },
	config = function()
		require("quarto").setup({
			lspFeatures = {
				enabled = true,
			},
		})
	end,
}
