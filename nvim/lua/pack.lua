-- BUILTIN plugins that require loading

-- undotree
vim.cmd("packadd nvim.undotree")

-- EXTERNAL plugins

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

-- helper
local gh = function(x)
  return "https://github.com/" .. x
end

-- Core plugins (always loaded)
vim.pack.add({
  gh("folke/which-key.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("nvim-mini/mini.statusline"),
  gh("christoomey/vim-tmux-navigator"),
  gh("stevearc/oil.nvim"),
  gh("stevearc/quicker.nvim"),
  gh("kylechui/nvim-surround"),
  gh("tpope/vim-fugitive"),
  gh("lewis6991/gitsigns.nvim"),
  gh("ibhagwan/fzf-lua"),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("nvim-treesitter/nvim-treesitter-textobjects"),
  gh("nvim-lua/plenary.nvim"),
  gh("R-nvim/R.nvim"),
})

-- Lazy-loaded plugins (load = false, triggered by autocmd)
vim.pack.add({
  gh("saghen/blink.cmp"),
  gh("rafamadriz/friendly-snippets"),
  gh("mason-org/mason.nvim"),
  gh("stevearc/conform.nvim"),
  gh("jpalardy/vim-slime"),
}, { load = false })

-- CONFIGURATION

-- which-key
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

-- nvim-web-devicons
require("nvim-web-devicons").setup({})

-- mini.statusline
local hl_fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg
local hl_bg = vim.api.nvim_get_hl(0, { name = "MinistatuslineFilename" }).bg
vim.api.nvim_set_hl(0, "StatuslineRec", { fg = hl_fg, bg = hl_bg, bold = true })

require("mini.statusline").setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 999 })
      local location = MiniStatusline.section_location({ trunc_width = 75 })
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
      local macro = ""
      local reg = vim.fn.reg_recording()
      if reg ~= "" then
        macro = "recording @" .. reg
      end

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDev", strings = { git, diff, diagnostics, lsp } },
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%<",
        "%=",
        { hl = "StatuslineRec", strings = { macro } },
        { hl = "MiniStatuslineFilename", strings = { fileinfo } },
        { strings = { search, location } },
      })
    end,
  },
  use_icons = true,
})

-- oil
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

vim.keymap.set("n", "<leader>t", function()
  local oil = require("oil")
  if vim.bo.filetype == "oil" then
    oil.close()
  else
    oil.open()
  end
end, { desc = "Toggle Oil file explorer" })

-- quicker
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

-- nvim-surround
require("nvim-surround").setup({
  move_cursor = false,
  surrounds = {
    ["c"] = { add = { "*", "*" }, find = "%*.-%*", delete = "^(%*)(.-)(%*)$" },
    ["n"] = { add = { "**", "**" }, find = "%*%*.-%*%*", delete = "^(%*%*)(.-)(%*%*)$" },
    ["g"] = { add = { "***", "***" }, find = "%*%*%*.-%*%*%*", delete = "^(%*%*%*)(.-)(%*%*%*)$" },
  },
})

vim.g.nvim_surround_no_normal_mappings = true
vim.keymap.set("n", "s", "<Plug>(nvim-surround-normal)", { desc = "Add surround (motion)" })
vim.keymap.set("n", "ss", "<Plug>(nvim-surround-normal-cur)", { desc = "Add surround around line" })
vim.keymap.set("n", "ds", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
vim.keymap.set("n", "cs", "<Plug>(nvim-surround-change)", { desc = "Change surround" })

-- fugitive Git keymaps
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

-- gitsigns
require("gitsigns").setup({
  current_line_blame = true,

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Navigation
    vim.keymap.set("n", "]g", function()
      if vim.wo.diff then
        return "]g"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Next hunk" })

    vim.keymap.set("n", "[g", function()
      if vim.wo.diff then
        return "[g"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "Prev hunk" })

    vim.keymap.set("n", "<leader>ss", gs.preview_hunk, { buffer = bufnr, desc = "Git diff (hunk)" })
    vim.keymap.set("n", "<leader>sr", gs.reset_hunk, { desc = "Reset hunk" })
    vim.keymap.set("v", "<leader>sr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Reset selection" })
  end,
})

-- fzf-lua
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
            ["<C-d>"] = "preview-down",
            ["<C-u>"] = "preview-up",
            ["ctrl-q"] = false,
          },
          fzf = {
            false,
            ["ctrl-z"] = "abort",
            ["ctrl-u"] = false,
            ["ctrl-l"] = "unix-line-discard+first",
            ["ctrl-a"] = "toggle-all",
            ["ctrl-r"] = "first",
            ["ctrl-e"] = "last",
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
            ["ctrl-t"] = actions.buf_tabedit,
          },
        },
        grep = { actions = { ["ctrl-f"] = { actions.grep_lgrep }, ["ctrl-g"] = false } },
        buffers = { actions = { ["ctrl-x"] = { fn = actions.buf_del, reload = true } } },
        fzf_opts = { ["--multi"] = true, ["--bind"] = "tab:toggle+down,shift-tab:toggle+up" },
      })
    end
    require("fzf-lua")[method](opts)
  end
end

vim.keymap.set("n", "<leader>fp", fzf("builtin"), { desc = "Find picker" })
vim.keymap.set("n", "<leader>ff", fzf("files"), { desc = "Find files" })
vim.keymap.set("n", "<leader>fz", fzf("zoxide"), { desc = "Find directories and cwd with zoxide" })
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
vim.keymap.set("n", "<leader>fS", fzf("lsp_document_symbols"), { desc = "Find LSP symbols" })
vim.keymap.set(
  "n",
  "<leader>fs",
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

-- Treesitter
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
      { "ai", "@conditional.outer", "Around conditional" },
      { "ii", "@conditional.inner", "Inside conditional" },
      { "ac", "@class.outer", "Around scope" },
      { "ic", "@class.inner", "Inside scope" },
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

-- R.nvim
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
      vim.api.nvim_echo({ { "" } }, false, {})
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

-- blink.cmp
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
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
      cmdline = {
        enabled = true,
        completion = {
          menu = { auto_show = true },
        },
      },
    })
  end,
})

-- mason
vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
  once = true,
  callback = function()
    require("mason").setup({
      ui = {
        border = "none",
        backdrop = 40,
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    })
  end,
})

-- conform
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  once = true,
  callback = function()
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

-- vim-slime
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "julia", "matlab", "quarto" },
  once = true,
  callback = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_no_mappings = 1
  end,
})

-- my plugins

local dev = vim.fn.expand("~/Documents/GitHub")
local my_packs = {
  "nightfox.nvim",
  "citeref.nvim",
  "replent.nvim",
  "learnlua.nvim",
}
for _, name in ipairs(my_packs) do
  vim.opt.rtp:prepend(dev .. "/" .. name)
end

require("nightfox").setup()

-- citeref
require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
})

-- replent
require("replent").setup({
  strategy = "tmux",
})
