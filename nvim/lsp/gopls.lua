return {
	cmd = { vim.fn.stdpath('data') .. '/mason/bin/gopls' },
	filetypes = { 'go', 'gomod' },
	root_markers = { 'go.mod', '.git' },
}
