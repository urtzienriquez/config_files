local gh = require("plugins.utils").gh

vim.pack.add({
  gh("saghen/blink.cmp"),
  gh("rafamadriz/friendly-snippets"),
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
    -- Add blink.cmp to rtp now so its plugin/ file sources for the first time here
    local blink_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/blink.cmp"
    vim.opt.rtp:append(blink_path)

    vim.cmd.packadd("friendly-snippets")
    require("blink.cmp").setup({
      keymap = {
        preset = "default",
        ["<C-Space>"] = {},
        ["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = { use_nvim_cmp_as_default = true, nerd_font_variant = "mono" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          citeref = { name = "citeref", module = "citeref.backends.blink" },
          snippets = { name = "snippets", opts = { score_offset = 100 } },
        },
        per_filetype = {
          markdown = { inherit_defaults = true, "citeref" },
          rmd = { inherit_defaults = true, "citeref" },
          quarto = { inherit_defaults = true, "citeref" },
          tex = { inherit_defaults = true, "citeref" },
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
    })
  end,
})
