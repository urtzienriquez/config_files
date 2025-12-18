return {
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd", "rnoweb", "quarto" },
	root_markers = { ".git" },
}
