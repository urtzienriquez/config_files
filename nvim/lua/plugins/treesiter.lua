return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
		config = function()
			local treesitter = require("nvim-treesitter")
			treesitter.setup({})
			local should_install = {
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

			local installed = treesitter.get_installed()
			local to_install = {}
			for _, lang in ipairs(should_install) do
				if not vim.tbl_contains(installed, lang) then
					table.insert(to_install, lang)
				end
			end
			treesitter.install(to_install)

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
						vim.treesitter.start(args.buf)
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
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
