vim.pack.add({ "https://github.com/tpope/vim-fugitive" })

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
  if not pcall(vim.api.nvim_buf_set_name, buf, "Git log") then
    pcall(vim.api.nvim_buf_set_name, buf, "Git log " .. buf)
  end
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
