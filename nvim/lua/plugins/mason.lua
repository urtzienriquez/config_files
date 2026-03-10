vim.pack.add({ "https://github.com/mason-org/mason.nvim" }, { load = false })

vim.api.nvim_create_user_command("Mason", function(cmd_opts)
  require("mason").setup({
    ui = {
      border = "none",
      backdrop = 40,
      icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
    },
  })
  vim.cmd("Mason " .. (cmd_opts.args or ""))
end, { nargs = "*" })
