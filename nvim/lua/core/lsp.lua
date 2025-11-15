-- nvim/lua/core/lsp.lua

-- Configure LSP borders
local border = "rounded"

-- Override the default LSP floating window handler to add borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or border
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Configure diagnostic floats to have borders
vim.diagnostic.config({
	float = { border = border },
})

-- Enable LSP servers
local servers = {
	"gopls",
	"r_language_server",
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
