vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/replent.nvim") --[[@as string]])

require("replent").setup({
  strategy = "neovim",
  repl_commands = { python = "PYTHON_HISTORY=/dev/null python3 -q" },
})
