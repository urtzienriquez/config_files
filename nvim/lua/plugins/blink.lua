return {
	"saghen/blink.cmp",
	dependencies = "rafamadriz/friendly-snippets",
	version = "*",
	opts = {
		keymap = {
			preset = "default",
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		completion = {
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
				show_documentation = true,
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
				vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#3d4865", fg = "#a9b1d6" })
				vim.api.nvim_set_hl(0, "CmpSel", { bg = "#2d3149", fg = "#c0caf5", bold = true })
				vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#3d4865", fg = "#a9b1d6" })
				vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = "#1a1b26", fg = "#a9b1d6" })
				vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#a9b1d6" })

				vim.api.nvim_set_hl(0, "Pmenu", { bg = "#3d4865" })
				vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2d3149" })
				vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#3d4865" })
				vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#2d3149" })
			else
				-- Light theme colors
				vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#CED3EB", fg = "#3760bf" })
				vim.api.nvim_set_hl(0, "CmpSel", { bg = "#c4c8da", fg = "#3760bf", bold = true })
				vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#CED3EB", fg = "#3760bf" })
				vim.api.nvim_set_hl(0, "CmpSignatureHelp", { bg = "#CED3EB", fg = "#3760bf" })

				vim.api.nvim_set_hl(0, "Pmenu", { bg = "#CED3EB" })
				vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#c4c8da" })
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
}
