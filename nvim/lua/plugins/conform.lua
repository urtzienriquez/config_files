return {
	"stevearc/conform.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>bf",
			function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 50000,
				})
			end,
			mode = { "n", "v" },
			desc = "Format buffer or range",
		},
	},
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				yaml = { "prettier" },
				markdown = { "prettier" },
				quarto = { "injected", "prettier" },
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
					prepend_args = function(self, ctx)
						local args = { "--single-quote" }
						if vim.bo[ctx.buf].filetype == "quarto" then
							table.insert(args, "--parser")
							table.insert(args, "markdown")
						end
						return args
					end,
				},
				-- Custom formatter for Quarto that handles R code chunks
				quarto_formatter = {
					command = "Rscript",
					args = {
						"-e",
						[[
                        library(knitr)
                        library(styler)
                        tmpfile <- commandArgs(TRUE)[1]
                        # Read the file
                        content <- readLines(tmpfile)
                        # Style R code chunks while preserving the rest
                        styled <- knitr::spin_child(tmpfile, format = "Rmd")
                        cat(styled, sep = "\n")
                        ]],
						"$FILENAME",
					},
					stdin = false,
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
