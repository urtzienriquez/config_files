return {
	{
		"saghen/blink.compat",
		version = "*",
		lazy = true,
		opts = {},
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"R-nvim/cmp-r",
			"archie-judd/blink-cmp-words",
		},
		version = "*",
		opts = {
			keymap = {
				preset = "default",
				["<C-Space>"] = {},
				["<C-j>"] = { "show", "show_documentation", "hide_documentation" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					r = { "path", "snippets", "R" },
					rmd = { inherit_defaults = true, "thesaurus", "R" },
					Rmd = { inherit_defaults = true, "thesaurus", "R" },
					jmd = { inherit_defaults = true, "thesaurus" },
					Jmd = { inherit_defaults = true, "thesaurus" },
					quarto = { inherit_defaults = true, "thesaurus", "R" },
					markdown = { inherit_defaults = true, "thesaurus" },
					text = { inherit_defaults = true, "thesaurus" },
				},
				providers = {
					R = {
						name = "cmp_r",
						module = "blink.compat.source",
						opts = {},
					},
					thesaurus = {
						name = "thesaurus",
						module = "blink-cmp-words.thesaurus",
						opts = {
							score_offset = 0,
							definition_pointers = { "!", "&", "^" },
							similarity_pointers = { "&", "^" },
							similarity_depth = 2,
						},
					},
				},
			},

			completion = {
				list = { selection = { preselect = true, auto_insert = true } },
				accept = { auto_brackets = { enabled = false } },

				menu = {
					auto_show_delay_ms = 500,
					border = "none",
					winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",

					draw = {
						columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "source_name", gap = 1 } },
					},
				},

				documentation = {
					auto_show = true,
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
		},

		config = function(_, opts)
			require("blink.cmp").setup(opts)

			-- Set up custom highlight groups for borderless completion
			local function setup_highlights()
				if vim.o.background == "dark" then
					-- Dark theme colors
					vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#373C52", fg = "#a9b1d6" })
					vim.api.nvim_set_hl(0, "CmpSel", { bg = "#4F5675", fg = "#c0caf5", bold = true })
					vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#373C52", fg = "#a9b1d6" })
					vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = "#373C52", fg = "#a9b1d6" })
					vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = "#373C52", fg = "#7dcfff" })

					vim.api.nvim_set_hl(0, "Pmenu", { bg = "#373C52" })
					vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#4F5675" })
					vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#373C52" })
					vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#373C52" })
				else
					-- Light theme colors
					vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#CED3EB", fg = "#3760bf" })
					vim.api.nvim_set_hl(0, "CmpSel", { bg = "#B4BEED", fg = "#3760bf", bold = true })
					vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#CED3EB", fg = "#3760bf" })
					vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = "#CED3EB", fg = "#3760bf" })
					vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = "#CED3EB", fg = "#3760bf" })

					vim.api.nvim_set_hl(0, "Pmenu", { bg = "#CED3EB" })
					vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#B4BEED" })
					vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#CED3EB" })
					vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#A6A9BA" })
				end
			end

			-- Apply highlights on startup and colorscheme changes
			setup_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = setup_highlights,
			})
		end,
	},
}
