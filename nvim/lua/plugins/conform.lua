local gh = require("plugins.utils").gh

vim.pack.add({ gh("stevearc/conform.nvim") })

-- vim.cmd.packadd("conform.nvim")
require("conform").setup({
  formatters_by_ft = {
    yaml = { "prettier" },
    markdown = { "prettier" },
    quarto = { "injected", "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
    fortran = { "fprettify" },
    r = { "styler" },
    julia = { "juliafmt" },
  },
  formatters = {
    injected = {
      condition = function()
        return true
      end,
      options = { ignore_errors = false, lang_to_formatters = {} },
    },
    styler = {
      command = "R",
      args = {
        "--slave",
        "--no-restore",
        "--no-save",
        "-e",
        "styler::style_file(commandArgs(TRUE), transformers = styler::tidyverse_style(indent_by = 2L, strict = TRUE))",
        "--args",
        "$FILENAME",
      },
      stdin = false,
    },
    prettier = {
      prepend_args = function(_, ctx)
        local args = { "--single-quote" }
        if vim.bo[ctx.buf].filetype == "quarto" then
          vim.list_extend(args, { "--parser", "markdown" })
        end
        return args
      end,
    },
    juliafmt = {
      command = "julia",
      args = {
        "--project=@lang_serv",
        "--startup-file=no",
        "-e",
        [[
              using JuliaFormatter
              text = read(stdin, String)
              formatted = format_text(text,
                always_for_in = true,
                separate_kwargs_with_semicolon = true,
              )
              print(formatted)
            ]],
      },
      stdin = true,
    },
    stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
  },
})
vim.keymap.set({ "n", "v" }, "<leader>bf", function()
  require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 50000 })
end, { desc = "Format buffer or range" })
