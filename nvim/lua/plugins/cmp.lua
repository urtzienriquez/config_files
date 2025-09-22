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
				vim_item.menu = string.format(" %s", source_mapping[entry.source.name] or "[Unknown]")
				return vim_item
			end,
			fields = { "abbr", "kind", "menu" },
		},
		window = {
			completion = {
				border = "none",
				winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
			},
			documentation = {
				border = "none",
				winhighlight = "Normal:CmpDoc,Search:None",
			},
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
		experimental = {
			ghost_text = false,
		},
	})

	-- Sync colors between nvim-cmp and CTRL-X completion
	local function set_completion_highlights()
		if vim.o.background == "dark" then
			-- Dark theme
			vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#3E4466" })
			vim.api.nvim_set_hl(0, "CmpSel", { bg = "#212436" })
			vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#3E4466" })
			vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#9854f1" })

			-- Built-in popup menu (CTRL-X completions)
			vim.api.nvim_set_hl(0, "Pmenu", { bg = "#3E4466" })
			vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#212436" })
			vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#3E4466" })
			vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#212436" })
		else
			-- Light theme
			vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#CED3EB" })
			vim.api.nvim_set_hl(0, "CmpSel", { bg = "#A6A9BA" })
			vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#CED3EB" })
			vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#007ea8" })

			vim.api.nvim_set_hl(0, "Pmenu", { bg = "#CED3EB" })
			vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#A6A9BA" })
			vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#CED3EB" })
			vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#A6A9BA" })
		end
	end

	-- Update highlights when colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = set_completion_highlights,
	})

	-- Apply immediately
	vim.defer_fn(set_completion_highlights, 0)
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
