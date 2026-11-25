vim.pack.add({ "https://github.com/jpalardy/vim-slime" })

vim.g.slime_no_mappings = 1
-- (the target: replent sets it on each send; for tmux, these)
vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
vim.g.slime_dont_ask_default = 1
