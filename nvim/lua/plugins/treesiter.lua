return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- optional: change install dir, etc.
			ts.setup({})

			local parsers = {
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"json",
				"julia",
				"latex",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"matlab",
				"python",
				"query",
				"r",
				"rnoweb",
				"vim",
				"vimdoc",
				"yaml",
				"regex",
			}

			-- Install asynchronously (or add :wait for sync bootstrap)
			ts.install(parsers)

			-- Start treesitter highlighting when the language is available
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end

					-- Safely attempt to start treesitter; if parser missing, no error
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					enable = true,
					lookahead = true,
					disable = { "fortran" },
				},
			})
		end,
	},
}
