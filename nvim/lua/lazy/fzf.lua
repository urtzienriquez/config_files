local M = {}

---@type fzf-lua?
local fzf = nil

local function get()
  if not fzf then
    M.setup()
  end
  if not fzf then
    error("fzf-lua failed to initialize")
  end
  return fzf
end

M.setup = function()
  if fzf then
    return
  end

  require("nvim-web-devicons").setup({})

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

  fzf = require("fzf-lua")
end

local function call(name)
  return function(...)
    return get()[name](...)
  end
end

M.builtin = call("builtin")
M.files = call("files")
M.zoxide = call("zoxide")
M.live_grep_native = call("live_grep_native")
M.grep_quickfix = call("grep_quickfix")
M.buffers = call("buffers")
M.help_tags = call("help_tags")
M.keymaps = call("keymaps")
M.grep_cword = call("grep_cword")
M.diagnostics_document = call("diagnostics_document")
M.diagnostics_workspace = call("diagnostics_workspace")
M.lsp_definitions = call("lsp_definitions")
M.lsp_references = call("lsp_references")
M.lsp_document_symbols = call("lsp_document_symbols")
M.treesitter = call("treesitter")
M.spell_suggest = call("spell_suggest")
M.marks = call("marks")
M.resume = call("resume")
M.oldfiles = call("oldfiles")
M.git_branches = call("git_branches")
M.git_commits = call("git_commits")

M.home_files = function()
  return (get().files({ cwd = vim.fn.expand("~"), prompt = "Home files❯ ", hidden = true }))
end

require("fzf-lua.providers.ui_select").register({
  winopts = {
    row = 0.5,
    col = 0.5,
    width = 0.5,
    height = 0.5,
    border = "rounded",
  },
})

return M
