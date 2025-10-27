-- nvim/lua/plugins/lsp.lua
-- Modern LSP configuration for Neovim 0.11+
-- Uses vim.lsp.config() and vim.lsp.enable() API

return {
	"neovim/nvim-lspconfig",
	config = function()
		-- Set up global capabilities for all LSP servers (from blink.cmp)
		vim.lsp.config('*', {
			capabilities = require('blink.cmp').get_lsp_capabilities(),
		})

		-- Each server config in nvim/lsp/ will be automatically loaded
		-- by Neovim during startup. These files should return a table with:
		-- { cmd = {...}, filetypes = {...}, root_markers = {...}, settings = {...} }
		
		-- List of language servers to enable
		-- These names must match the filenames in nvim/lsp/
		local servers = {
			'gopls',
			'r_language_server',
			'matlab_language_server',
			'pyright',
			'ts_ls',
			'julials',
			'fortls',
			'lua_ls',
			'marksman',
			'yamlls',
		}

		-- Enable all language servers
		-- This creates FileType autocommands that start each server
		-- only when a matching filetype is opened
		vim.lsp.enable(servers)
	end,
}
