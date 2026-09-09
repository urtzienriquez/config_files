local M = {}

local fzf = nil

local function get()
  if not fzf then
    M.setup()
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

for _, name in ipairs({
  "builtin",
  "files",
  "zoxide",
  "live_grep_native",
  "grep_quickfix",
  "buffers",
  "help_tags",
  "keymaps",
  "grep_cword",
  "diagnostics_document",
  "diagnostics_workspace",
  "lsp_definitions",
  "lsp_references",
  "lsp_document_symbols",
  "treesitter",
  "spell_suggest",
  "marks",
  "resume",
  "oldfiles",
  "git_branches",
  "git_commits",
}) do
  M[name] = function(...)
    return get()[name](...)
  end
end

M.home_files = function()
  return get().files({ cwd = vim.fn.expand("~"), prompt = "Home files❯ ", hidden = true })
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
