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

local ops = require("plugins.dirvish")
vim.keymap.set("n", "mf", ops.mkfile, opts)
vim.keymap.set("n", "md", ops.mkdir, opts)
vim.keymap.set("n", "r", ops.rename, opts)
vim.keymap.set("n", "cp", ops.copy, opts)
vim.keymap.set("n", "mv", ops.move, opts)
vim.keymap.set("n", "dd", ops.remove, opts)
vim.keymap.set("x", "dd", ops.remove_visual, opts)
