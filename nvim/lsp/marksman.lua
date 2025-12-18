return {
	cmd = { vim.fn.stdpath('data') .. '/mason/bin/marksman', 'server' },
	filetypes = { 'rmd', 'markdown', 'quarto' },
	root_markers = { '.marksman.toml', '_quarto.yml', '.git' },
}
