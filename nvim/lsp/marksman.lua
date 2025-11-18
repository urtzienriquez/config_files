-- nvim/lsp/marksman.lua
-- Markdown language server configuration (including Quarto)

return {
	cmd = { vim.fn.stdpath('data') .. '/mason/bin/marksman', 'server' },
	filetypes = { 'rmd', 'markdown', 'markdown.mdx', 'quarto' },
	root_markers = { '.marksman.toml', '_quarto.yml', '.git' },
}
