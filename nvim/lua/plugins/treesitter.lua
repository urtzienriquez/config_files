return {
	{
		"nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"rnoweb", -- for Rmarkdown
				"yaml",
				"r",
				"julia",
				"matlab",
					"python",
					"javascript",
					"css",
					"json",
				"latex",
			},
				auto_install = true,
				sync_install = false,
				ignore_install = {},
				modules = {},
			highlight = {
				enable = true,
				disable = { "fortran" },
					additional_vim_regex_highlighting = { "ruby", "markdown" },
			},
			indent = {
				enable = true,
				disable = { "ruby", "fortran" },
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					disable = { "fortran" },
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",
					},
				},
			},
			})
		end,
		dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		},
	},
}
