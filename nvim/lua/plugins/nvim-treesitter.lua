vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
})

vim.api.nvim_create_autocmd("FileType", {
  once = true,
  callback = function()
    require("nvim-treesitter").setup({})
    require("nvim-treesitter").install({
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
    })
    require("nvim-treesitter-textobjects").setup({
      select = {
        enable = true,
        lookahead = true,
        disable = function(lang, buf)
          return lang == "fortran" and vim.api.nvim_buf_get_name(buf):match("%.f$") ~= nil
        end,
      },
    })

    -- Enable treesitter for all subsequent filetypes
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

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.f",
      callback = function(args)
        if vim.treesitter.highlighter.active[args.buf] then
          vim.treesitter.stop(args.buf)
        end
      end,
    })

    -- Textobject keymaps
    local ts_select = require("nvim-treesitter-textobjects.select")
    for _, map in ipairs({
      { "af", "@function.outer", "Around function" },
      { "if", "@function.inner", "Inside function" },
      { "al", "@loop.outer", "Around loop" },
      { "il", "@loop.inner", "Inside loop" },
      { "ac", "@conditional.outer", "Around conditional" },
      { "ic", "@conditional.inner", "Inside conditional" },
    }) do
      vim.keymap.set({ "x", "o" }, map[1], function()
        ts_select.select_textobject(map[2], "textobjects")
      end, { desc = map[3] })
    end

    -- Apply treesitter to the buffer that triggered this autocmd
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if lang then
      pcall(vim.treesitter.start, vim.api.nvim_get_current_buf())
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
