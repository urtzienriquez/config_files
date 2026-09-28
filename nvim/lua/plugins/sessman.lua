vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/sessman.nvim") --[[@as string]])

vim.g.sessman_exclude = {
  "R-console",
  "term://*:julia*",
  "term://*:python*",
  "term://*:matlab*",
}

vim.keymap.set("n", "<leader>ss", "<Cmd>Session<CR>", { desc = "session manager" })
vim.keymap.set("n", "<leader>sc", "<Cmd>Session connect<CR>", { desc = "Connect to a server" })
vim.keymap.set("n", "<leader>sl", "<Cmd>Session load<CR>", { desc = "Load a session" })
vim.keymap.set("n", "<leader>sw", "<Cmd>Session save<CR>", { desc = "save session" })
