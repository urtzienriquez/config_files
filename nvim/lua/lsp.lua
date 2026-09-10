-- Enable LSP servers (deferred: load vim.lsp + enable on first real file)
local servers = {
  "clangd",
  "gopls",
  "r_language_server",
  "matlab_language_server",
  "pyright",
  "ts_ls",
  "julials",
  "fortls",
  "emmylua_ls",
  "marksman",
  "yamlls",
  "jsonls",
  "texlab",
}

vim.api.nvim_create_autocmd("FileType", {
  once = true,
  callback = function()
    vim.lsp.enable(servers)
  end,
})
