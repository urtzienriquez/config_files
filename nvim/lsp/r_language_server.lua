-- nvim/lsp/r_language_server.lua
-- R language server configuration

return {
	cmd = { 'R', '--slave', '-e', 'languageserver::run()' },
	filetypes = { 'r', 'rmd', 'quarto' },
	root_markers = { '.git' },
}
