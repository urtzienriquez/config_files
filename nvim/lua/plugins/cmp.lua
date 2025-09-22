local function configure_cmp()
	local cmp = require("cmp")

	local source_mapping = {
		nvim_lsp = "[LSP]",
		luasnip = "[LuaSnip]",
		path = "[Path]",
		buffer = "[Buffer]",
		latex_symbols = "[LaTeX]",
		cmp_r = "[R]",
	}

	cmp.setup({
		-- Expand snippets with cmp_luasnip
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "latex_symbols" },
			{ name = "cmp_r" },
		}, {
			{ name = "buffer" },
		}),
		completion = {
			keyword_length = 2,
			completeopt = "menu,menuone,noselect,popup",
		},
		formatting = {
			format = function(entry, vim_item)
				vim_item.menu = source_mapping[entry.source.name] or "[Unknown]"

				vim_item.menu = string.format(" %s", vim_item.menu)

				return vim_item
			end,
			fields = { "abbr", "kind", "menu" },
		},
		window = {
			completion = cmp.config.window.bordered({
				winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
			}),
			documentation = cmp.config.window.bordered({
				winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
			}),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<C-j>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
				else
					fallback()
				end
			end, { "i", "s" }),
			["<C-k>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		-- Add experimental features that might help
		experimental = {
			ghost_text = false, -- Disable if causing issues
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
			{ "kdheepak/cmp-latex-symbols" },
			{ "R-nvim/cmp-r" },
			{ "L3MON4D3/LuaSnip" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		config = configure_cmp,
	},
}
