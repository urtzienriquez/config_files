vim.pack.add({ "https://github.com/jpalardy/vim-slime" }, { load = false })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "julia", "matlab", "quarto" },
  once = true,
  callback = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_no_mappings = 1
    vim.g.slime_bracketed_paste = 1
  end,
})
