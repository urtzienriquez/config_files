-- Enable LSP servers
local servers = {
	"gopls",
	"r_language_server",
    "r_ls",
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
