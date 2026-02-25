return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "*",
  event = { "CmdlineEnter", "InsertEnter" },
  opts = {
    keymap = {
      preset = "default",
      ["<C-Space>"] = {},
      ["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        citeref = { name = "citeref", module = "citeref.backends.blink" },
        snippets = {
          name = "snippets",
          opts = {
            score_offset = 100,
          },
        },
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
      menu = {
        draw = {
          columns = { { "label", gap = 1 }, { "kind_icon", "source_name", gap = 1 } },
        },
      },
      documentation = {
        auto_show = true,
        treesitter_highlighting = true,
      },
      ghost_text = { enabled = false },
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = true,
      },
    },
  },
}
