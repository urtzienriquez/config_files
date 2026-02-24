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
				citeref = { name = "citeref", module = "citeref.backends.blink" },
				snippets = {
					name = "snippets",
					opts = {
						score_offset = 100,
					},
				},
			},
			per_filetype = {
				markdown = { inherit_defaults = true, "citeref" },
				rmd = { inherit_defaults = true, "citeref" },
				quarto = { inherit_defaults = true, "citeref" },
				tex = { inherit_defaults = true, "citeref" },
			},
		},

		completion = {
			list = { selection = { preselect = true, auto_insert = false } },
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
	},
}
