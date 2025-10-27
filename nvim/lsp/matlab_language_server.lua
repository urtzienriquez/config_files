-- nvim/lsp/matlab_language_server.lua
-- MATLAB language server configuration

return {
	cmd = { 'matlab-language-server', '--stdio' },
	filetypes = { 'matlab' },
	root_markers = { '.git' },
	settings = {
		MATLAB = {
			indexWorkspace = true,
			matlabConnectionTiming = 'onStart',
			telemetry = false,
		},
	},
}
