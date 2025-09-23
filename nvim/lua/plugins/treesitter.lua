return {
	-- Main Treesitter plugin
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		priority = 100, -- Load early
		opts = {
			ensure_installed = {
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
				"rnoweb", -- for Rmarkdown
				"vim",
				"vimdoc",
				"yaml",
			},
			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
				disable = { "fortran" },
				additional_vim_regex_highlighting = false,
			},

			indent = {
				enable = true,
				disable = { "python", "fortran" },
			},
		},

		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	-- Treesitter textobjects (depends on nvim-treesitter)
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter", branch = "main" },
		},
		event = "VeryLazy",
		opts = {
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
