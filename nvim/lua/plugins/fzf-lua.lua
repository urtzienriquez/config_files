vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf = {}

---@type fzf-lua?
local fzf_lua = nil

local function fzf_setup()
  if fzf_lua then
    return
  end

  local actions = require("fzf-lua").actions

  require("fzf-lua").setup({
    defaults = { no_header_i = true, file_icons = false, actions = { ["ctrl-q"] = actions.file_sel_to_qf } },
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
        ["ctrl-u"] = false,
        ["ctrl-z"] = "unix-line-discard+first",
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

  fzf_lua = require("fzf-lua")

  require("fzf-lua.providers.ui_select").register({
    winopts = {
      row = 0.5,
      col = 0.5,
      width = 0.5,
      height = 0.5,
      border = "rounded",
    },
  })
end

-- first vim.ui.select call triggers the registration
vim.ui.select = function(...)
  fzf_setup()
  return vim.ui.select(...)
end

local function fzf_get()
  if not fzf_lua then
    fzf_setup()
  end
  if not fzf_lua then
    error("fzf-lua failed to initialize")
  end
  return fzf_lua
end

local function fzf_call(name)
  return function(...)
    return fzf_get()[name](...)
  end
end

fzf.builtin = fzf_call("builtin")
fzf.files = fzf_call("files")
fzf.zoxide = fzf_call("zoxide")
fzf.live_grep_native = fzf_call("live_grep_native")
fzf.grep_quickfix = fzf_call("grep_quickfix")
fzf.buffers = function(opts)
  opts = opts or {}
  if opts.filter == nil then
    -- filter out guh://... buffers: they have their own picker
    opts.filter = function(b)
      return not vim.api.nvim_buf_get_name(b):match("^guh://")
    end
  end
  opts.fzf_opts = opts.fzf_opts or {}
  if opts.fzf_opts["--header-lines"] == nil then
    if not opts.filter(vim.api.nvim_get_current_buf()) then
      opts.fzf_opts["--header-lines"] = false
    end
  end
  return fzf_get().buffers(opts)
end
fzf.help_tags = fzf_call("help_tags")
fzf.keymaps = fzf_call("keymaps")
fzf.grep_cword = fzf_call("grep_cword")
fzf.diagnostics_document = fzf_call("diagnostics_document")
fzf.diagnostics_workspace = fzf_call("diagnostics_workspace")
fzf.lsp_definitions = fzf_call("lsp_definitions")
fzf.lsp_references = fzf_call("lsp_references")
fzf.lsp_document_symbols = fzf_call("lsp_document_symbols")
fzf.treesitter = fzf_call("treesitter")
fzf.spell_suggest = fzf_call("spell_suggest")
fzf.marks = fzf_call("marks")
fzf.resume = fzf_call("resume")
fzf.oldfiles = fzf_call("oldfiles")
fzf.git_branches = fzf_call("git_branches")
fzf.git_commits = fzf_call("git_commits")

fzf.home_files = function()
  return (fzf_get().files({ cwd = vim.fn.expand("~"), prompt = "Home files❯ ", hidden = true }))
end

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

return { fzf = fzf, get = fzf_get }
