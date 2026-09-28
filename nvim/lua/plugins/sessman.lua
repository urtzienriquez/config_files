vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/sessman.nvim") --[[@as string]])

vim.g.sessman_exclude = {
  "R-console",
  "term://*:julia*",
  "term://*:python*",
  "term://*:matlab*",
}

vim.keymap.set("n", "<leader>ss", "<Cmd>Session<CR>", { desc = "session manager" })
vim.keymap.set("n", "<leader>sl", function()
  require("sessman").switch({ running = false })
end, { desc = "load session" })
vim.keymap.set("n", "<leader>sm", function()
  require("sessman").switch({ running = true })
end, { desc = "load session" })
vim.keymap.set("n", "<leader>sw", "<Cmd>Session save<CR>", { desc = "save session" })
