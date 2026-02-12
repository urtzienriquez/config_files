return {
	"mason-org/mason.nvim",
	event = "VeryLazy",
	config = function()
		-- import mason
		local mason = require("mason")

		mason.setup({
			ui = {
				backdrop = 40,
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
	end,
}
