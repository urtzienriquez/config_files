local gh = function(x)
  return "https://github.com/" .. x
end

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

-- Plugin list
vim.pack.add({
  gh("folke/which-key.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("nvim-lua/plenary.nvim"),
  gh("christoomey/vim-tmux-navigator"),
  gh("stevearc/oil.nvim"),
  gh("ibhagwan/fzf-lua"),
  gh("saghen/blink.cmp"),
  gh("rafamadriz/friendly-snippets"),
  gh("stevearc/conform.nvim"),
  gh("mason-org/mason.nvim"),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("nvim-treesitter/nvim-treesitter-textobjects"),
  gh("kylechui/nvim-surround"),
  gh("tpope/vim-fugitive"),
  gh("jpalardy/vim-slime"),
  gh("R-nvim/R.nvim"),
}, { load = false })

-- Dev plugins
local dev = vim.fn.expand("~/Documents/GitHub")
for _, name in ipairs({ "nightfox.nvim", "citeref.nvim", "replent.nvim", "learnlua.nvim" }) do
  vim.opt.rtp:prepend(dev .. "/" .. name)
end

-- ALWAYS LOADED

vim.cmd.colorscheme("nightfox")

vim.cmd.packadd("plenary.nvim")
vim.cmd.packadd("vim-tmux-navigator")

vim.cmd.packadd("oil.nvim")
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

vim.cmd.packadd("which-key.nvim")
require("which-key").setup({
  plugins = { spelling = { enabled = false } },
  delay = 0,
  preset = "helix",
  icons = { mappings = vim.g.have_nerd_font },
})

-- citeref: always loaded so blink.cmp can use its source from first InsertEnter,
-- regardless of which filetype was opened first.
require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
})

-- plenary test runner
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

-- UIEnter

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    -- nvim-web-devicons: deferred from startup into UIEnter
    vim.cmd.packadd("nvim-web-devicons")
    require("nvim-web-devicons").setup({})

    -- nvim-surround
    vim.cmd.packadd("nvim-surround")
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

    -- vim-fugitive
    vim.cmd.packadd("vim-fugitive")
    vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
    vim.keymap.set("n", "<leader>gf", "<cmd>Git fetch<cr>", { desc = "Git fetch" })
    vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git pull" })
    vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })
    vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<cr>", { desc = "Git blame" })
    vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
    vim.keymap.set("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })
    vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit!<cr>", { desc = "Git diff split" })
    vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage)" })
    vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout)" })

    -- mason + conform
    vim.cmd.packadd("mason.nvim")
    require("mason").setup({
      ui = {
        border = "none",
        backdrop = 40,
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    })
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

    -- which-key groups
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

    -- oil toggle
    vim.keymap.set("n", "<leader>t", function()
      local oil = require("oil")
      if vim.bo.filetype == "oil" then
        oil.close()
      else
        oil.open()
      end
    end, { desc = "Toggle Oil file explorer" })

    -- UI toggles
    local function toggle(option, on_val, off_val)
      return function()
        if vim.o[option] == off_val then
          vim.o[option] = on_val
          vim.notify(option .. " enabled", vim.log.levels.INFO)
        else
          vim.o[option] = off_val
          vim.notify(option .. " disabled", vim.log.levels.INFO)
        end
      end
    end
    vim.keymap.set("n", "<leader>uS", toggle("spell", true, false), { desc = "Toggle Spelling" })
    vim.keymap.set("n", "<leader>us", function()
      if vim.bo.spelllang == "es_es" then
        vim.cmd("SpellEN")
      else
        vim.cmd("SpellES")
      end
    end, { desc = "Toggle Spell Language" })
    vim.keymap.set("n", "<leader>uu", function()
      vim.cmd("!lig")
    end, { silent = true, desc = "Toggle ligatures" })
    vim.keymap.set("n", "<leader>uw", toggle("wrap", true, false), { desc = "Toggle Wrap" })
    vim.keymap.set("n", "<leader>uo", toggle("scrolloff", 10, 0), { desc = "Toggle Scrolloff" })
    vim.keymap.set("n", "<leader>uc", toggle("cursorlineopt", "both", "number"), { desc = "Toggle Cursorline" })
    vim.keymap.set("n", "<leader>ul", toggle("relativenumber", true, false), { desc = "Toggle Relative Numbers" })
    vim.keymap.set("n", "<leader>uL", function()
      vim.wo.number = not vim.wo.number
      vim.o.relativenumber = vim.wo.number
      vim.notify("line numbers " .. (vim.wo.number and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle All Line Numbers" })
    vim.keymap.set("n", "<leader>ub", function()
      if vim.o.background == "dark" then
        vim.cmd.colorscheme("dayfox")
        vim.notify("colorscheme = dayfox", vim.log.levels.INFO)
      else
        vim.cmd.colorscheme("nightfox")
        vim.notify("colorscheme = nightfox", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Background" })
    vim.keymap.set("n", "<leader>ux", function()
      vim.o.conceallevel = vim.o.conceallevel > 0 and 0 or 2
      vim.notify("Conceal " .. (vim.o.conceallevel > 0 and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle Conceal" })
    vim.keymap.set("n", "<leader>ud", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle Diagnostics" })
    vim.keymap.set("n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      vim.notify("Inlay hints " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
    end, { desc = "Toggle Inlay Hints" })
    vim.keymap.set("n", "<leader>uT", function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.treesitter.highlighter.active[buf] then
        vim.treesitter.stop(buf)
        vim.notify("Treesitter disabled", vim.log.levels.INFO)
      else
        vim.treesitter.start(buf)
        vim.notify("Treesitter enabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle Treesitter" })
  end,
})

-- InsertEnter / CmdlineEnter  →  blink.cmp
-- blink.cmp's rtp is only added here to prevent its plugin/ file from sourcing at startup

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

-- first FileType  →  nvim-treesitter

vim.api.nvim_create_autocmd("FileType", {
  once = true,
  callback = function()
    vim.cmd.packadd("nvim-treesitter")
    vim.cmd.packadd("nvim-treesitter-textobjects")

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

-- FileType  →  R.nvim

vim.cmd.packadd("R.nvim")

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
  vim.keymap.set("n", "<leader>cn", "<Plug>RNextRChunk", o)
  vim.keymap.set("n", "<leader>cN", "<Plug>RPreviousRChunk", o)
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

-- FileType  →  vim-slime + replent.nvim

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

-- fzf-lua  →  load on first keypress

local _fzf_loaded = false
local function fzf(method, opts)
  return function()
    if not _fzf_loaded then
      _fzf_loaded = true
      vim.cmd.packadd("fzf-lua")
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

-- commands

vim.api.nvim_create_user_command("Mason", function(cmd_opts)
  vim.cmd.packadd("mason.nvim")
  require("mason").setup({
    ui = {
      border = "none",
      backdrop = 40,
      icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
    },
  })
  vim.cmd("Mason " .. (cmd_opts.args or ""))
end, { nargs = "*" })

vim.api.nvim_create_user_command("Learn", function()
  vim.cmd("Learn")
end, {})
