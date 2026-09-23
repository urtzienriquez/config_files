local opts = { silent = true, buffer = true }

vim.keymap.set('n', 't', '<Cmd>call dirvish#open("tabedit", 0)<CR>', opts)
vim.keymap.set('x', 't', '<Cmd>call dirvish#open("tabedit", 0)<CR>', opts)
vim.keymap.set(
  'n',
  'gh',
  [[:silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>:setl cole=3<cr>]],
  opts
)
vim.keymap.set("n", "_", function()
  vim.cmd("Dirvish " .. vim.fn.getcwd())
end, opts)

local dirvish = require("plugins.dirvish")

-- real Ex commands (instead of input()) so <C-f> opens the cmdline window
vim.api.nvim_buf_create_user_command(0, "DirvishMkfile", function(o) dirvish.mkfile(o.args) end, { nargs = 1 })
vim.api.nvim_buf_create_user_command(0, "DirvishMkdir", function(o) dirvish.mkdir(o.args) end, { nargs = 1 })
vim.api.nvim_buf_create_user_command(0, "DirvishRename", function(o) dirvish.rename(o.args) end, { nargs = 1 })

-- not silent: the pre-typed command line must stay visible
vim.keymap.set("n", "mf", ":DirvishMkfile ", { buffer = true })
vim.keymap.set("n", "md", ":DirvishMkdir ", { buffer = true })
vim.keymap.set("n", "r", function()
  return ":DirvishRename " .. dirvish.current_name()
end, { buffer = true, expr = true, replace_keycodes = false })
vim.keymap.set("n", "cp", dirvish.copy, opts)
vim.keymap.set("n", "mv", dirvish.move, opts)
vim.keymap.set("n", "dd", dirvish.remove, opts)
vim.keymap.set("x", "dd", dirvish.remove_visual, opts)
