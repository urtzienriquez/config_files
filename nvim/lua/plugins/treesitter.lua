return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
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
				"python",  -- Added for better support
				"javascript",  -- Added for web content in markdown
				"css",  -- Added for styling in markdown
				"json",  -- Added for JSON blocks in markdown
			},
			auto_install = true,  -- Changed to true to automatically install missing parsers
			highlight = {
				enable = true,
				disable = { "fortran" },
				additional_vim_regex_highlighting = { "ruby", "markdown" },  -- Added markdown for better highlighting
			},
			indent = {
				enable = true,
				disable = { "ruby" },
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
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
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
