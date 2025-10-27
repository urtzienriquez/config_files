-- nvim/lsp/gopls.lua
-- Go language server configuration

return {
	cmd = { 'gopls' },
	filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
	root_markers = { 'go.mod', '.git' },
}
