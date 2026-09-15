local opts = { silent = true, buffer = true }

vim.keymap.set('n', 't', '<Cmd>call dirvish#open("tabedit", 0)<CR>', opts)
vim.keymap.set('x', 't', '<Cmd>call dirvish#open("tabedit", 0)<CR>', opts)
vim.keymap.set(
  'n',
  'gh',
  [[:silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>:setl cole=3<cr>]],
  opts
)
