return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      -- optional: change install dir, etc.
      ts.setup({})
      local parsers = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "javascript",
        "json",
        "julia",
        "latex",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "matlab",
        "python",
        "query",
        "r",
        "rnoweb",
        "vim",
        "vimdoc",
        "yaml",
        "regex",
        "fortran",
      }
      ts.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end

          pcall(vim.treesitter.start, args.buf)

          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })

      -- stop treesitter on fortran77 (.f) files
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.f",
        callback = function(args)
          if vim.treesitter.highlighter.active[args.buf] then
            vim.treesitter.stop(args.buf)
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          -- Disable for Fortran77 files
          disable = function(lang, buf)
            if lang == "fortran" then
              local filename = vim.api.nvim_buf_get_name(buf)
              return filename:match("%.f$") ~= nil
            end
            return false
          end,
        },
      })
    end,
  },
}
