return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	version = "*",
	event = { "CmdlineEnter", "InsertEnter" },
	opts = {
		keymap = {
			preset = "default",
			["<C-Space>"] = {},
			["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				snippets = {
					name = "snippets",
					opts = {
						score_offset = 100,
					},
				},
			},
		},

		completion = {
			list = { selection = { preselect = true, auto_insert = true } },
			accept = { auto_brackets = { enabled = false } },

			menu = {
				border = "none",
				winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",

				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "source_name", gap = 1 } },
				},
			},

			documentation = {
				auto_show = false,
				treesitter_highlighting = true,
				window = {
					border = "none",
					winhighlight = "Normal:CmpDoc,Search:None",
				},
			},

			ghost_text = { enabled = false },
		},

		signature = {
			enabled = true,
			window = {
				show_documentation = false,
				border = "none",
				winhighlight = "Normal:CmpSignatureHelp",
			},
		},

		-- fuzzy = {
		-- 	sorts = {
		-- 		"exact", -- Prioritize exact matches first
		-- 		"sort_text", -- Then use the LSP's sortText
		-- 		"score", -- Fallback to fuzzy matching score
		-- 		"label", -- Finally, sort by the display label
		-- 	},
		-- },
	},

	config = function(_, opts)
		require("blink.cmp").setup(opts)

		local function setup_highlights()
			local ok, palette = pcall(require("nightfox.palette").load, vim.g.colors_name or "nightfox")
			if not ok then
				return
			end

			if vim.o.background == "dark" then
				vim.api.nvim_set_hl(0, "CmpPmenu", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "CmpSel", { bg = palette.sel1, fg = palette.fg1, bold = true })
				vim.api.nvim_set_hl(0, "CmpDoc", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = palette.bg2, fg = palette.blue.base })

				vim.api.nvim_set_hl(0, "Pmenu", { bg = palette.bg2 })
				vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.sel1 })
				vim.api.nvim_set_hl(0, "PmenuSbar", { bg = palette.bg2 })
				vim.api.nvim_set_hl(0, "PmenuThumb", { bg = palette.bg3 })
			else
				vim.api.nvim_set_hl(0, "CmpPmenu", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "CmpSel", { bg = palette.sel0, fg = palette.fg1, bold = true })
				vim.api.nvim_set_hl(0, "CmpDoc", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = palette.bg2, fg = palette.fg2 })
				vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = palette.bg2, fg = palette.blue.base })

				vim.api.nvim_set_hl(0, "Pmenu", { bg = palette.bg2 })
				vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.sel0 })
				vim.api.nvim_set_hl(0, "PmenuSbar", { bg = palette.bg2 })
				vim.api.nvim_set_hl(0, "PmenuThumb", { bg = palette.bg3 })
			end
		end

		-- Apply highlights on startup and colorscheme changes
		setup_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = setup_highlights,
		})
	end,
}
