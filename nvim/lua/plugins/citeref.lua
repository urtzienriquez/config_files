return {
	"urtzienriquez/citeref.nvim",
    dev = false,
	dependencies = { "ibhagwan/fzf-lua" },
	config = function()
		require("citeref").setup({
			bib_files = { "~/Documents/zotero.bib" },
		})
	end,
}
