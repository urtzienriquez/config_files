-- nvim/lsp/texlab.lua
-- LaTeX language server configuration

return {
	cmd = { "texlab" },
	filetypes = { "tex", "plaintex", "bib" },
	root_markers = {
		".latexmkrc",
		".git",
		"texlabconfig.toml",
		"Tectonic.toml",
	},
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
				onSave = true,
			},
			chktex = {
				onEdit = false,
				onOpenAndSave = true,
			},
			forwardSearch = {
				executable = nil, -- Set to your PDF viewer
				args = {},
			},
		},
	},
}
