return {
	"urtzienriquez/citeref.nvim",
	dev = false,
	ft = { "markdown", "rmd", "quarto", "rnoweb", "pandoc", "tex", "latex" },
	config = function()
		require("citeref").setup({
			backend = "fzf",
			bib_files = { "~/Documents/zotero.bib" },
		})
	end,
}
