-- nvim/lua/core/lsp.lua

-- Enable LSP servers
local servers = {
	"gopls",
	-- "r_language_server", -- now provided by R-nvim's rnvimserver
	"matlab_language_server",
	"pyright",
	"ts_ls",
	"julials",
	"fortls",
	"lua_ls",
	"marksman",
	"yamlls",
	"jsonls",
}

vim.lsp.enable(servers)
