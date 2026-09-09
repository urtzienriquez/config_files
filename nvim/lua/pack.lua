-- hooks
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
    if name == "LuaSnip" and (kind == "install" or kind == "update") then
      vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
    end
  end,
})

----------------------------------------
-- builtin plugins that require loading

-- undotree
vim.cmd("packadd nvim.undotree")

----------------------------------------
-- external plugins

-- helper
local gh = function(x)
  return "https://github.com/" .. x
end

vim.pack.add({
  gh("nvim-tree/nvim-web-devicons"),
  gh("nvim-mini/mini.clue"),
  gh("nvim-mini/mini.statusline"),
  gh("kylechui/nvim-surround"),
  gh("lewis6991/gitsigns.nvim"),
  gh("ibhagwan/fzf-lua"),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("nvim-treesitter/nvim-treesitter-textobjects"),
  gh("nvim-lua/plenary.nvim"),
  { src = gh("saghen/blink.cmp"), version = "v1" },
  gh("rafamadriz/friendly-snippets"),
  gh("L3MON4D3/LuaSnip"),
  gh("mason-org/mason.nvim"),
  gh("stevearc/conform.nvim"),
  gh("jpalardy/vim-slime"),
  gh("stevearc/oil.nvim"),
  gh("stevearc/quicker.nvim"),
  gh("tpope/vim-fugitive"),
  gh("pwntester/octo.nvim"),
  gh("R-nvim/R.nvim"),
  gh("nickjvandyke/opencode.nvim"),
})

----------------------------------------
-- my plugins

local dev = vim.fn.expand("~/Documents/GitHub")
local my_packs = {
  "nightfox.nvim",
  "zotero.nvim",
  "citeref.nvim",
  "replent.nvim",
  "sessman.nvim",
  "bs.nvim",
}
for _, name in ipairs(my_packs) do
  vim.opt.rtp:prepend(dev .. "/" .. name)
end

----------------------------------------
-- configuration

-- mini.clue
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "<LocalLeader>" },
    { mode = { "n", "x" }, keys = "[" },
    { mode = { "n", "x" }, keys = "]" },
    { mode = "n", keys = "c" },
    { mode = "n", keys = "d" },
    { mode = "i", keys = "<C-x>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = { "n", "x" }, keys = "z" },
  },

  window = {
    delay = 500,
    config = { width = 50 },
  },

  clues = {
    miniclue.gen_clues.g(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.z(),
    { mode = { "n", "x" }, keys = "go", desc = "Add range to opencode" },

    -- leader groups (universal only; filetype-specific groups are declared
    -- buffer-locally in the relevant ftplugin files via vim.b.miniclue_config)
    { mode = "n", keys = "<Leader>f", desc = "(Find commands)" },
    { mode = "n", keys = "<Leader>g", desc = "(Git commands)" },
    { mode = "n", keys = "<Leader>h", desc = "(GitHub)" },
    { mode = "n", keys = "<Leader>i", desc = "(opencode)" },
    { mode = "n", keys = "<Leader>u", desc = "(UI)" },
    { mode = "n", keys = "<Leader>b", desc = "(Buffer format)" },
    { mode = "n", keys = "<Leader>m", desc = "(Session)" },
    { mode = "n", keys = "<Leader>z", desc = "(Zotero)" },
  },
})

-- mini.statusline
local statusline = require("mini.statusline")

local fileinfo = function()
  local filetype = vim.bo.filetype
  local devicons = require("nvim-web-devicons")
  local icon = devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true }) .. " "
  return string.format("%s%s", icon, filetype)
end

local contents = function()
  local mode, mode_hl = statusline.section_mode({ trunc_width = 50 })
  local git = statusline.section_git({ trunc_width = 40 })
  local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
  local lsp = statusline.section_lsp({ trunc_width = 75 })
  local filename = statusline.section_filename({ trunc_width = 100 })
  local location = "%l,%2v"
  local search = statusline.section_searchcount({ trunc_width = 75 })

  return statusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics, lsp } },
    "%<",
    { hl = "MiniStatuslineFilename", strings = { filename } },
    "%=",
    { hl = "MiniStatuslineFileinfo", strings = { fileinfo() } },
    { hl = mode_hl, strings = { search, location } },
  })
end

statusline.setup({
  content = { active = contents },
})

-- oil (lazy: set up on first use)
local oil = require("lazy.oil")
vim.keymap.set("n", "-", function()
  oil.setup()
  vim.cmd("Oil")
end, { desc = "Open file explorer (oil)" })

-- quicker (lazy-loaded on quickfix FileType)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  once = true,
  callback = function()
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
  end,
})

-- nvim-surround
require("nvim-surround").setup({
  move_cursor = false,
  surrounds = {
    ["c"] = { add = { "*", "*" }, find = "%*.-%*", delete = "^(%*)(.-)(%*)$" },
    ["n"] = { add = { "**", "**" }, find = "%*%*.-%*%*", delete = "^(%*%*)(.-)(%*%*)$" },
    ["g"] = { add = { "***", "***" }, find = "%*%*%*.-%*%*%*", delete = "^(%*%*%*)(.-)(%*%*%*)$" },
    ["l"] = {
      add = function()
        local config = require("nvim-surround.config")
        local result = config.get_input("Enter LaTeX command: ")
        if result then
          return { { "\\" .. result .. "{" }, { "}" } }
        end
      end,
    },
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
vim.keymap.set("n", "<leader>gL", "<cmd>Git log<cr>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gl", function()
  local root = vim.fs.root(0, ".git")
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  local prev = vim.fn.getcwd()
  vim.cmd("lcd " .. vim.fn.fnameescape(root))
  vim.cmd("hori terminal git log --color --graph --decorate --oneline --all")
  vim.cmd("lcd " .. vim.fn.fnameescape(prev))
  local buf = vim.api.nvim_get_current_buf()
  vim.keymap.set("t", "gq", function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf, desc = "Close git log terminal" })
  vim.cmd("startinsert")
end, { desc = "Git log graph (terminal, colored)" })
vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<cr>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<cr>", { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage)" })
vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout)" })

-- octo.nvim (lazy: setup on first use via :Octo shim)
local octo = require("lazy.octo")
local function octo_cmd(...)
  octo.setup()
  vim.cmd(...)
end
vim.keymap.set("n", "<leader>hh", function()
  octo_cmd("Octo")
end, { desc = "List octo actions" })
vim.keymap.set("n", "<leader>hi", function()
  octo_cmd("Octo issue list")
end, { desc = "List issues" })
vim.keymap.set("n", "<leader>hp", function()
  octo_cmd("Octo pr list")
end, { desc = "List PRs" })
vim.keymap.set("n", "<leader>hs", function()
  octo_cmd("Octo search")
end, { desc = "Search GitHub" })
vim.keymap.set("n", "<leader>hr", function()
  octo_cmd("Octo repo view")
end, { desc = "View repo" })

-- gitsigns (plugin file auto-setups on rtp load; options set here)
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

    vim.keymap.set("n", "<leader>gS", gs.preview_hunk, { buffer = bufnr, desc = "Git diff (hunk)" })
    vim.keymap.set("n", "<leader>gR", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
    vim.keymap.set("v", "<leader>gR", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "Reset selection" })
  end,
})

-- fzf-lua (lazy: set up on first use)
local fzf = require("lazy.fzf")

vim.keymap.set("n", "<leader>fp", fzf.builtin, { desc = "picker" })
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "files" })
vim.keymap.set("n", "<leader>fz", fzf.zoxide, { desc = "zoxide" })
vim.keymap.set("n", "<leader>f~", fzf.home_files, { desc = "Find files in ~" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep_native, { desc = "with grep" })
vim.keymap.set("n", "<leader>fq", fzf.grep_quickfix, { desc = "grep quickfix" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "buffers" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "help" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "keymaps" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "word" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "diagnostics (buffer)" })
vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "diagnostics (workspace)" })
vim.keymap.set("n", "<leader>fl", fzf.lsp_definitions, { desc = "LSP definitions" })
vim.keymap.set("n", "<leader>fr", fzf.lsp_references, { desc = "LSP references" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "LSP symbols" })
vim.keymap.set("n", "<leader>ft", fzf.treesitter, { desc = "Treesitter symbols" })
vim.keymap.set("n", "<leader>fm", fzf.spell_suggest, { desc = "Spell suggestions" })
vim.keymap.set("n", "<leader>f'", fzf.marks, { desc = "marks" })
vim.keymap.set("n", "<leader>f,", fzf.resume, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>f.", fzf.oldfiles, { desc = "recent files" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gC", fzf.git_commits, { desc = "Git commits" })

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

-- add tree-sitter-jnoweb
vim.filetype.add({
  extension = {
    jnw = "jnoweb",
  },
})
vim.treesitter.language.add("jnoweb", {
  path = "/home/urtzi/.local/share/nvim/site/parser/jnoweb.so",
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

-- blink.cmp
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = function()
    pcall(vim.cmd, "packadd LuaSnip")
    local loader = require("luasnip.loaders.from_vscode")
    loader.lazy_load({
      paths = { vim.fn.stdpath("config") .. "/snippets" },
    })
    loader.lazy_load()
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
      require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 50000 })
    end, { desc = "Format buffer or range" })
  end,
})

-- vim-slime
vim.g.slime_no_mappings = 1
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "julia", "matlab", "quarto", "jnoweb" },
  once = true,
  callback = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
  end,
})

-- R.nvim
local function set_rnvim_keymaps()
  local o = { noremap = true, silent = true, buffer = true }
  local function opts(desc)
    return vim.tbl_extend("force", o, { desc = desc })
  end
  vim.keymap.set("n", "<leader>or", "<Plug>RStart", opts("Start R"))
  vim.keymap.set("n", "<leader>qr", "<Plug>RClose", opts("Close R"))
  vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", opts("Set working directory"))
  vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts("Send line to R"))
  vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts("Send selection to R"))
  vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", opts("Send buffer to R"))
  vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", opts("R help"))
  vim.keymap.set("n", "<leader>ro", "<Plug>ROBToggle", opts("Toggle object browser"))
  vim.keymap.set("n", "]]", "<Plug>RNextRChunk", opts("Next R chunk"))
  vim.keymap.set("n", "[[", "<Plug>RPreviousRChunk", opts("Previous R chunk"))
  vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", opts("Add inline R code"))
  vim.keymap.set("n", "<leader>cc", "i`r<Space>`<Esc>i", opts("Add inline R code"))

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
    end, opts("Render R Markdown"))
  elseif vim.bo.filetype == "rnoweb" then
    vim.keymap.set("n", "<leader>rr", function()
      local filename = vim.fn.input({ prompt = "Output filename (without extension): ", cancelreturn = "__CANCEL__" })
      vim.api.nvim_echo({ { "" } }, false, {})
      if filename == "__CANCEL__" then
        return
      end
      local file = vim.fn.expand("%")
      local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
      for _, line in ipairs(lines) do
        local root = line:match("^%% *!%a+ *root *= *(%S+)")
        if root then
          file = root
          break
        end
      end
      local tex_file, r_cmd
      if filename ~= "" then
        tex_file = filename .. ".tex"
        r_cmd = string.format('knitrmini::knit("%s", output = "%s", engine = "lualatex")', file, tex_file, tex_file)
      else
        tex_file = file:gsub(".Rnw$", ".tex")
        r_cmd = string.format('knitrmini::knit("%s", engine = "lualatex")', file, tex_file)
      end
      vim.cmd("RSend " .. r_cmd)
      vim.api.nvim_echo({ { "Compiling with latexmk using root: " .. file, "Normal" } }, false, {})
    end, opts("Render Rnoweb with latexmk"))
    vim.keymap.set("n", "<leader>rc", function()
      local file_dir = vim.fn.expand("%:p:h")
      local file_name = vim.fn.expand("%:t:r")
      local extensions = {
        "aux",
        "bcf",
        "run.xml",
        "log",
        "listing",
        "out",
        "toc",
        "nav",
        "snm",
        "vrb",
        "fls",
        "fdb_latexmk",
        "blg",
        "bbl",
        "synctex.gz",
      }
      local extra_files = {
        file_name .. "-tikzDictionary",
      }
      local count = 0
      for _, ext in ipairs(extensions) do
        local target = file_dir .. "/" .. file_name .. "." .. ext
        if vim.fn.filereadable(target) == 1 then
          os.remove(target)
          count = count + 1
        end
      end
      for _, extra in ipairs(extra_files) do
        local target = file_dir .. "/" .. extra
        if vim.fn.filereadable(target) == 1 then
          os.remove(target)
          count = count + 1
        end
      end
      if count > 0 then
        print("Cleaned " .. count .. " auxiliary files.")
      else
        print("No auxiliary files found to clean.")
      end
    end, { desc = "Clean LaTeX/Rnoweb auxiliary files" })
  end
end

local r_opts = {
  R_app = "R",
  bracketed_paste = false,
  R_args = { "--no-save --silent" },
  buffer_opts = "winfixwidth winfixheight",
  user_maps_only = true,
  objbr_mappings = {
    c = "class",
    ["<leader>gp"] = "head({object}, n = 15)",
    v = function()
      require("r.browser").toggle_view()
    end,
  },
  hook = {
    after_R_start = function()
      vim.notify("R was launched")
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" and buf ~= vim.api.nvim_get_current_buf() then
          pcall(vim.api.nvim_buf_set_name, buf, "R-console")
          break
        end
      end
    end,
    on_filetype = function()
      if vim.bo.filetype ~= "quarto" and vim.bo.filetype ~= "jnoweb" then
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

-- opencode.nvim
vim.keymap.set({ "n", "x" }, "<leader>io", function()
  require("opencode").select()
end, { desc = "OpenCode actions" })
vim.keymap.set({ "n", "x" }, "<leader>ia", function()
  require("opencode").ask()
end, { desc = "Ask opencode ask" })
vim.keymap.set({ "n", "x" }, "go", function()
  return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })
vim.keymap.set("n", "<C-M-b>", function()
  require("opencode").command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })
vim.keymap.set("n", "<C-M-f>", function()
  require("opencode").command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })

-- nightfox
require("nightfox").setup()

-- zotero.nvim
require("zotero").setup({
  backend = "fzf",
  max_items = "3000",
})

-- citeref
require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
  default_latex_format = "parencite",
  picker = { rnoweb_labels = "tex_only" },
})

-- replent
require("replent").setup({
  strategy = "neovim",
  repl_commands = { python = "PYTHON_HISTORY=/dev/null python3 -q" },
})

-- sessman
require("sessman").setup({
  backend = "fzf",
})

-- bs
require("bs").setup({})
