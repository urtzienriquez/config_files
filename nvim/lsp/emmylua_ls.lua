return {
  cmd = { "emmylua_ls" },
  filetypes = { "lua" },
  root_markers = { { ".emmyrc.json", ".luarc.json" }, ".git" },
  settings = {
    emmylua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(
          vim.api.nvim_get_runtime_file("", true),
          { vim.fn.expand("~/.local/share/lua-libraries/love2d/library") }
        ),
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
