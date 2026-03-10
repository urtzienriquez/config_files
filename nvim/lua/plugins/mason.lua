vim.pack.add({ "https://github.com/mason-org/mason.nvim" }, { load = false })

  require("mason").setup({
    ui = {
      border = "none",
      backdrop = 40,
      icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
    },
  })
