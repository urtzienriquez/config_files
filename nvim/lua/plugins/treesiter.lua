return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
		config = function()
			local treesitter = require("nvim-treesitter")
			treesitter.setup({})
			local should_install = {
				"vim",
				"c",
				"xml",
				"css",
				"bash",
				"diff",
				"lua",
				"luap",
				"luadoc",
				"vim",
				"vimdoc",
				"typescript",
				"javascript",
				"jsdoc",
				"html",
				"http",
				"json",
				"jsonc",
				"sql",
				"python",
				"julia",
				"matlab",
        "r",
        "rnoweb",
        "latex",
				"csv",
				"gitignore",
				"gitcommit",
				"gitattributes",
				"git_config",
				"go",
				"query",
				"toml",
				"yaml",
				"regex",
				"markdown",
				"markdown_inline",
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
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "V",
					},
					include_surrounding_whitespace = true,
				},
				move = {
					set_jumps = false,
				},
			})
			do -- move
				vim.keymap.set({ "n", "x", "o" }, "]]", function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
					vim.cmd("normal! zz")
				end)
				vim.keymap.set({ "n", "x", "o" }, "[[", function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
					vim.cmd("normal! zz")
				end)
			end
		end,
	},
}
