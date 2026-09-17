vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- make mason-installed formatters/linters resolvable by conform
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  once = true,
  callback = function()
    require("conform").setup({
      formatters_by_ft = {
        yaml = { "prettier" },
        markdown = { "prettier" },
        quarto = { "injected", "prettier" },
        rmd = { "literateR_fmt" },
        rnoweb = { "literateR_fmt" },
        tex = { "literateR_fmt" },
        plaintex = { "literateR_fmt" },
        jnoweb = { "jnoweb_fmt" },
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
          options = {
            ignore_errors = false,
            lang_to_formatters = {
              yaml = { "prettier" },
              latex = { "latexindent" },
              r = { "styler" },
            },
          },
        },
        literateR_fmt = {
          command = "literateR-fmt",
          stdin = true,
        },
        jnoweb_fmt = {
          command = "jnoweb-fmt",
          stdin = true,
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
      -- conform.FormatOpts is (exact); all-reported fields are optional at runtime
      ---@diagnostic disable-next-line: param-type-mismatch
      require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 50000 })
    end, { desc = "Format buffer or range" })
  end,
})
