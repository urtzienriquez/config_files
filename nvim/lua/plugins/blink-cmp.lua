vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = "v1" },
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/L3MON4D3/LuaSnip",
}, { load = function() end })

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
    for _, name in ipairs({ "friendly-snippets", "LuaSnip", "blink.cmp" }) do
      pcall(vim.cmd.packadd, name)
    end
    local loader = require("luasnip.loaders.from_vscode")
    loader.lazy_load({
      paths = { vim.fn.stdpath("config") .. "/snippets" },
    })
    loader.lazy_load()
    ---@diagnostic disable: missing-fields, assign-type-mismatch, param-type-mismatch
    require("blink.cmp").setup({
      keymap = {
        preset = "default",
        ["<C-k>"] = false,
      },
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          citeref = { name = "citeref", module = "citeref.backends.blink" },
          snippets = {
            name = "snippets",
            -- score_offset = 100,
          },
        },
        per_filetype = {
          markdown = { inherit_defaults = true, "citeref" },
          rmd = { inherit_defaults = true, "citeref" },
          quarto = { inherit_defaults = true, "citeref" },
          tex = { inherit_defaults = true, "citeref" },
          rnoweb = { inherit_defaults = true, "citeref" },
        },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        accept = { auto_brackets = { enabled = false } },
        menu = { draw = { columns = { { "label", gap = 1 }, { "kind_icon", "source_name", gap = 1 } } } },
        documentation = { auto_show = true, treesitter_highlighting = true },
        ghost_text = { enabled = false },
      },
      signature = { enabled = true, window = { show_documentation = true } },
      cmdline = { enabled = false },
    })
    ---@diagnostic enable: missing-fields, assign-type-mismatch, param-type-mismatch
  end,
})
