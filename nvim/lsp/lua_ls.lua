return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(
          vim.api.nvim_get_runtime_file("", true),
          { vim.fn.expand("~/.local/share/lua-libraries/love2d/library") }
        ),
      },
      telemetry = { enable = false },
    },
  },
}
