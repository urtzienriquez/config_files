vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

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
