return {
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd", "Rmd", "rnoweb", "quarto" },
	root_markers = { ".git" },
}
