return {
  "tpope/vim-fugitive",
  config = function()
    -- Set up keymaps
    vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
    vim.keymap.set("n", "<leader>gf", "<cmd>Git fetch<cr>", { desc = "Git fetch" })
    vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git pull" })
    vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })
    vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<cr>", { desc = "Git blame" })
    vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
    vim.keymap.set("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })
    vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit!<cr>", { desc = "Git diff split" })
    vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage current file)" })
    vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout current file)" })
  end,
}
