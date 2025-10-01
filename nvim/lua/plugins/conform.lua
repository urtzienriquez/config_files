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
				julia = { "juliafmt" },
			},
			formatters = {
				styler = {
					command = "R",
					args = {
						"--slave",
						"--no-restore",
						"--no-save",
						"-e",
                        "styler::style_file(commandArgs(TRUE), transformers = styler::tidyverse_style(indent_by = 4L, strict = TRUE))",
						"--args",
						"$FILENAME",
					},
					stdin = false,
				},
				prettier = {
					prepend_args = { "--single-quote" },
				},
				juliafmt = {
					command = "julia",
					args = {
						"--startup-file=no",
						"-e",
						[[
        using JuliaFormatter
        text = read(stdin, String)
        formatted = format_text(text, 
          always_for_in = true,
          separate_kwargs_with_semicolon = true,
        )
        print(formatted)
        ]],
					},
					stdin = true,
				},
			},
		})
	end,
}
