return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				yaml = { "prettier" },
				markdown = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				lua = { "stylua" },
				python = { "black" },
				fortran = { "fprettify" },
				r = { "styler" },
			},
			formatters = {
				prettier = {
					prepend_args = { "--single-quote" },
				},
			},
		})
	end,
}
