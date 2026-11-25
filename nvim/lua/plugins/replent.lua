vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/replent.nvim") --[[@as string]])

require("replent").setup({
  strategy = "neovim",
  -- the same keys as R.nvim's in every language: <leader>or / <leader>qr start / stop this file's REPL
  keymaps = {
    start_python = "<leader>or", start_julia = "<leader>or", start_matlab = "<leader>or",
    close_python = "<leader>qr", close_julia = "<leader>qr", close_matlab = "<leader>qr",
  },
  repl_commands = { python = "PYTHON_HISTORY=/dev/null python3 -q" },
})
