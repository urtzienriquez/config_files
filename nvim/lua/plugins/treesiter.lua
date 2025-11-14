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
				"fortran",
			}
			-- Install asynchronously (or add :wait for sync bootstrap)
			ts.install(parsers)
			-- Start treesitter highlighting when the language is available
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					-- Disable treesitter completely for Fortran77 files (.f extension)
					if args.match == "fortran" then
						local filename = vim.api.nvim_buf_get_name(args.buf)
						if filename:match("%.f$") then
							-- Explicitly stop treesitter if it's running
							pcall(vim.treesitter.stop, args.buf)
							return
						end
					end

					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end

					-- Safely attempt to start treesitter; if parser missing, no error
					pcall(vim.treesitter.start, args.buf)

					-- folding based on treesitter
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})

			-- Additional safeguard: stop treesitter if it somehow starts on .f files
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.f",
				callback = function(args)
					if vim.treesitter.highlighter.active[args.buf] then
						vim.treesitter.stop(args.buf)
					end
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
					-- Disable for Fortran77 files using a function
					disable = function(lang, buf)
						if lang == "fortran" then
							local filename = vim.api.nvim_buf_get_name(buf)
							return filename:match("%.f$") ~= nil
						end
						return false
					end,
				},
			})
		end,
	},
}
