-- Build hooks (must be before vim.pack.add)
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
    if name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
    end
  end,
})

-- ============================================================================
-- STRATEGY 1: Load all plugins at once (fastest startup)
-- ============================================================================

-- Core plugins (always loaded)
vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/R-nvim/R.nvim",
  "https://github.com/kylechui/nvim-surround",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/stevearc/quicker.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/folke/which-key.nvim",
})

-- Lazy-loaded plugins (load = false, triggered by autocmd)
vim.pack.add({
  "https://github.com/saghen/blink.cmp",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/jpalardy/vim-slime",
}, { load = false })

-- ============================================================================
-- CONFIGURE PLUGINS (after loading)
-- ============================================================================

-- Configure core plugins immediately
require("nvim-web-devicons")
require("oil").setup({
  default_file_explorer = true,
  use_default_keymaps = true,
  view_options = { show_hidden = true },
  keymaps = {
    ["t"] = { "actions.parent", mode = "n" },
    ["<C-h>"] = false,
    ["<C-l>"] = false,
    ["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
    ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
    ["<leader>l"] = "actions.refresh",
  },
})

require("nvim-surround").setup({
  move_cursor = false,
  surrounds = {
    ["c"] = { add = { "*", "*" }, find = "%*.-%*", delete = "^(%*)(.-)(%*)$" },
    ["n"] = { add = { "**", "**" }, find = "%*%*.-%*%*", delete = "^(%*%*)(.-)(%*%*)$" },
    ["g"] = { add = { "***", "***" }, find = "%*%*%*.-%*%*%*", delete = "^(%*%*%*)(.-)(%*%*%*)$" },
    ["q"] = {
      add = { "\u{201C}", "\u{201D}" },
      find = "\u{201C}.-\u{201D}",
      delete = "^(\u{201C})(.-)(\\u{201D})$",
    },
    ["s"] = { add = { "'", "'" } },
  },
})

require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})

require("which-key").setup({
  plugins = { spelling = { enabled = false } },
  delay = 0,
  preset = "helix",
  icons = { mappings = vim.g.have_nerd_font },
})

require("which-key").add({
  { "<leader>f", name = "Find" },
  { "<leader>fd", name = "diagnostics" },
  { "<leader>b", name = "Buffer" },
  { "<leader>c", name = "cd / code block" },
  { "<leader>o", name = "Open REPL" },
  { "<leader>q", name = "Close REPL" },
  { "<leader>r", name = "R / Render / Run" },
  { "<leader>s", name = "Send" },
  { "<leader>u", name = "UI toggle" },
  { "<leader>a", name = "Add" },
  { "<leader>g", name = "Git" },
})

-- R.nvim configuration
local function set_rnvim_keymaps()
  local o = { noremap = true, silent = true, buffer = true }
  vim.keymap.set("n", "<leader>or", "<Plug>RStart", o)
  vim.keymap.set("n", "<leader>qr", "<Plug>RClose", o)
  vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", o)
  vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", o)
  vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", o)
  vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", o)
  vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", o)
  vim.keymap.set("n", "<leader>ro", "<Plug>ROBToggle", o)
  vim.keymap.set("n", "]]", "<Plug>RNextRChunk", o)
  vim.keymap.set("n", "[[", "<Plug>RPreviousRChunk", o)
  vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", o)
  vim.keymap.set("n", "<leader>ac", "i`r<Space>`<Esc>i", vim.tbl_extend("force", o, { desc = "Add inline code" }))
  if vim.bo.filetype == "rmd" then
    vim.keymap.set("n", "<leader>rr", function()
      local filename = vim.fn.input({ prompt = "Output filename (without extension): ", cancelreturn = "__CANCEL__" })
      vim.api.nvim_echo({}, false, {})
      if filename == "__CANCEL__" then
        return
      end
      vim.cmd('RSend if(exists("params")) rm(params)')
      local file = vim.fn.expand("%")
      if filename ~= "" then
        vim.cmd('RSend rmarkdown::render("' .. file .. '", output_file = "' .. filename .. '")')
      else
        vim.cmd('RSend rmarkdown::render("' .. file .. '")')
      end
    end, { desc = "Render R Markdown" })
  end
end

local r_opts = {
  R_app = "R",
  external_term = "tmux split-window -d -h",
  bracketed_paste = false,
  R_args = { "--no-save --silent" },
  user_maps_only = true,
  r_ls = {
    completion = true,
    hover = true,
    signature = true,
    implementation = false,
    definition = false,
    references = false,
  },
  objbr_mappings = {
    c = "class",
    ["<leader>gp"] = "head({object}, n = 15)",
    v = function()
      require("r.browser").toggle_view()
    end,
  },
  hook = {
    on_filetype = function()
      if vim.bo.filetype ~= "quarto" then
        set_rnvim_keymaps()
        return
      end
      for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do
        local lang = line:match("^```{(%w+)")
        if lang and lang:lower() == "r" then
          set_rnvim_keymaps()
          return
        end
      end
    end,
  },
}
if vim.env.R_AUTO_START == "true" then
  r_opts.auto_start = "on startup"
  r_opts.objbr_auto_start = true
end

require("r").setup(r_opts)

-- Treesitter (one-time setup on first FileType)
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

    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if lang then
      pcall(vim.treesitter.start, vim.api.nvim_get_current_buf())
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- FZF-lua (lazy setup)
local _fzf_loaded = false
local function fzf(method, opts)
  return function()
    if not _fzf_loaded then
      _fzf_loaded = true
      local actions = require("fzf-lua").actions
      require("fzf-lua").setup({
        defaults = { no_header_i = true, actions = { ["ctrl-q"] = actions.file_sel_to_qf } },
        keymap = {
          builtin = {
            false,
            ["<M-Esc>"] = "hide",
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            ["<F3>"] = "toggle-preview-wrap",
            ["<F4>"] = "toggle-preview",
            ["<F5>"] = "toggle-preview-cw",
            ["<F6>"] = "toggle-preview-behavior",
            ["<F7>"] = "toggle-preview-ts-ctx",
            ["<F8>"] = "preview-ts-ctx-dec",
            ["<F9>"] = "preview-ts-ctx-inc",
            ["<S-Left>"] = "preview-reset",
            ["<M-S-j>"] = "preview-down",
            ["<M-S-k>"] = "preview-up",
            ["ctrl-q"] = false,
          },
          fzf = {
            false,
            ["ctrl-z"] = "abort",
            ["ctrl-u"] = "unix-line-discard+first",
            ["ctrl-a"] = "toggle-all",
            ["ctrl-t"] = "first",
            ["ctrl-b"] = "last",
            ["ctrl-q"] = false,
          },
        },
        actions = {
          files = {
            ["enter"] = actions.file_edit_or_qf,
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-j"] = actions.toggle_ignore,
            ["ctrl-h"] = actions.toggle_hidden,
            ["ctrl-f"] = actions.toggle_follow,
          },
        },
        grep = { actions = { ["ctrl-f"] = { actions.grep_lgrep }, ["ctrl-g"] = false } },
        buffers = { actions = { ["ctrl-d"] = { fn = actions.buf_del, reload = true }, ["ctrl-x"] = false } },
        fzf_opts = { ["--multi"] = true, ["--bind"] = "tab:toggle+down,shift-tab:toggle+up" },
        fzf_colors = {
          ["fg"] = { "fg", "Normal" },
          ["bg"] = { "bg", "Normal" },
          ["fg+"] = { "fg", "Normal" },
          ["bg+"] = { "bg", "CursorLine" },
          ["hl"] = { "fg", "Comment" },
          ["hl+"] = { "fg", "Statement" },
          ["gutter"] = { "bg", "Normal" },
        },
      })
    end
    require("fzf-lua")[method](opts)
  end
end

-- FZF keymaps
vim.keymap.set("n", "<leader>fp", fzf("builtin"), { desc = "Find picker" })
vim.keymap.set("n", "<leader>ff", fzf("files"), { desc = "Find files" })
vim.keymap.set(
  "n",
  "<leader>f~",
  fzf("files", { cwd = vim.fn.expand("~"), prompt = "Home files❯ ", hidden = true }),
  { desc = "Find files in ~" }
)
vim.keymap.set("n", "<leader>fg", fzf("live_grep"), { desc = "Find with grep" })
vim.keymap.set("n", "<leader>fq", fzf("grep_quickfix"), { desc = "Grep quickfix" })
vim.keymap.set("n", "<leader>fb", fzf("buffers"), { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", fzf("help_tags"), { desc = "Find help" })
vim.keymap.set("n", "<leader>fk", fzf("keymaps"), { desc = "Find keymaps" })
vim.keymap.set("n", "<leader>fw", fzf("grep_cword"), { desc = "Find word" })
vim.keymap.set("n", "<leader>fd", fzf("diagnostics_document"), { desc = "Find diagnostics (buffer)" })
vim.keymap.set("n", "<leader>fD", fzf("diagnostics_workspace"), { desc = "Find diagnostics (workspace)" })
vim.keymap.set("n", "<leader>fl", fzf("lsp_definitions"), { desc = "Find LSP definitions" })
vim.keymap.set("n", "<leader>fr", fzf("lsp_references"), { desc = "Find LSP references" })
vim.keymap.set("n", "<leader>fs", fzf("lsp_document_symbols"), { desc = "Find LSP symbols" })
vim.keymap.set(
  "n",
  "<leader>fS",
  fzf("lsp_document_symbols", { regex_filter = "Str.*" }),
  { desc = "Find LSP symbols (strings)" }
)
vim.keymap.set("n", "<leader>ft", fzf("treesitter"), { desc = "Find Treesitter symbols" })
vim.keymap.set("n", "<leader>fm", fzf("spell_suggest"), { desc = "Spell suggestions" })
vim.keymap.set("n", "<leader>f'", fzf("marks"), { desc = "Find marks" })
vim.keymap.set("n", "<leader>f,", fzf("resume"), { desc = "Resume picker" })
vim.keymap.set("n", "<leader>f.", fzf("oldfiles"), { desc = "Find recent files" })
vim.keymap.set("n", "<leader>gb", fzf("git_branches"), { desc = "Git branches" })
vim.keymap.set("n", "<leader>gC", fzf("git_commits"), { desc = "Git commits" })

-- Oil keymap
vim.keymap.set("n", "<leader>t", function()
  local oil = require("oil")
  if vim.bo.filetype == "oil" then
    oil.close()
  else
    oil.open()
  end
end, { desc = "Toggle Oil file explorer" })

-- Git keymaps
vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gf", "<cmd>Git fetch<cr>", { desc = "Git fetch" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gL", "<cmd>Git log --graph --decorate --oneline --all<cr>", { desc = "Git log graph" })
vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<cr>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit!<cr>", { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage)" })
vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout)" })

-- Plenary test runner
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = "*_spec.lua",
  callback = function(ev)
    vim.keymap.set("n", "<leader>rt", function()
      local prev = vim.o.winborder
      vim.o.winborder = "none"
      vim.cmd("PlenaryBustedFile %")
      vim.o.winborder = prev
    end, { buffer = ev.buf, desc = "Run tests (plenary)" })
  end,
})

-- ============================================================================
-- LAZY-LOADED PLUGIN CONFIGURATION
-- ============================================================================

-- Blink.cmp (loads on insert/cmdline)
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
    vim.cmd.packadd("blink.cmp")
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

-- Conform (loads on BufEnter)
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  once = true,
  callback = function()
    vim.cmd.packadd("conform.nvim")
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
  end,
})

-- Mason (no immediate trigger needed)
vim.cmd.packadd("mason.nvim")
require("mason").setup({
  ui = {
    border = "none",
    backdrop = 40,
    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

-- Vim-slime (loads on specific filetypes)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "julia", "matlab", "quarto" },
  once = true,
  callback = function()
    vim.cmd.packadd("vim-slime")
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_no_mappings = 1
    vim.g.slime_bracketed_paste = 1
  end,
})

-- ============================================================================
-- MY DEV PLUGINS
-- ============================================================================

local dev = vim.fn.expand("~/Documents/GitHub")
local my_packs = {
  "nightfox.nvim",
  "citeref.nvim",
  "replent.nvim",
  "learnlua.nvim",
  "neoffice.nvim",
}
for _, name in ipairs(my_packs) do
  vim.opt.rtp:prepend(dev .. "/" .. name)
end

vim.cmd.colorscheme("nightfox")

require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
})

require("neoffice").setup({})
