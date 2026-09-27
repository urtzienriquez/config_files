vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/sessman.nvim") --[[@as string]])

vim.keymap.set("n", "<leader>ss", "<Cmd>Session<CR>", {desc = "session manager"})
vim.keymap.set("n", "<leader>sl", function() require("sessman").pick() end, {desc = "load session"})
vim.keymap.set("n", "<leader>sw", "<Cmd>Session save<CR>", {desc = "save session"})
