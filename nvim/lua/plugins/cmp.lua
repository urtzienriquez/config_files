-- Completions with nvim-cmp and friends
-- https://github.com/hrsh7th/nvim-cmp

local function configure_cmp()
	local cmp = require("cmp")

	local source_mapping = {
		nvim_lsp = "[LSP]",
		luasnip = "[LuaSnip]",
		path = "[Path]",
		buffer = "[Buffer]",
	}

	cmp.setup({
		-- Expand snippets with cmp_luasnip
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		-- TODO: Why are these separate? Priority?
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
		}, {
			{ name = "buffer" },
		}),
		completion = {
			keyword_length = 3,
			completeopt = "menu,menuone,noselect",
		},
		formatting = {
			format = function(entry, vim_item)
				vim_item.menu = source_mapping[entry.source.name]
				return vim_item
			end,
		},
	})
end

return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "R-nvim/cmp-r" },
			-- Snippet engine(s) required for nvim-cmp (expands things from LS)
			{ "L3MON4D3/LuaSnip" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		config = configure_cmp,
	},
}
