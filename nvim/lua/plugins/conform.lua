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
			},
			formatters = {
				prettier = {
					prepend_args = { "--single-quote" },
				},
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>bf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
