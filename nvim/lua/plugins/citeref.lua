return {
	"urtzienriquez/citeref.nvim",
	dev = false,
	ft = { "markdown", "rmd", "quarto", "rnoweb", "pandoc", "tex", "latex" },
	dependencies = { "ibhagwan/fzf-lua" },
	config = function()
		require("citeref").setup({
			bib_files = { "~/Documents/zotero.bib" },
		})
	end,
}
