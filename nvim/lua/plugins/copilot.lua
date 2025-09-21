return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{
				"github/copilot.vim",
				config = function()
					-- Disable Copilot by default
					vim.g.copilot_enabled = false

					-- Disable default Tab mapping
					vim.g.copilot_no_tab_map = true

					-- Set custom keybinding for accept suggestion
					vim.keymap.set("i", "<M-a>", 'copilot#Accept("\\<CR>")', {
						expr = true,
						replace_keycodes = false,
					})

					-- Optional: Additional Copilot keybindings
					vim.keymap.set("i", "<M-]>", "copilot#Next()", { expr = true })
					vim.keymap.set("i", "<M-[>", "copilot#Previous()", { expr = true })
					vim.keymap.set("i", "<M-d>", "copilot#Dismiss()", { expr = true })
				end,
			},
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			debug = false,
			show_help = true,
			auto_follow_cursor = false,
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")

			-- Set selection method
			opts.selection = select.unnamed

			-- Setup the plugin first
			chat.setup(opts)

			-- Create custom commands with explicit buffer selection
			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual })
			end, { nargs = "*", range = true })
		end,
		event = "VeryLazy",
		keys = {
			-- Basic chat commands
			{ "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle CopilotChat" },
			{ "<leader>cx", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
			{ "<leader>ct", "<cmd>CopilotChatTests<cr>", desc = "Generate tests" },
			{ "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "Review code" },

			-- Visual mode chat
			{
				"<leader>cv",
				":CopilotChatVisual ",
				mode = "x",
				desc = "Chat with visual selection",
			},

			-- Quick chat
			{
				"<leader>cq",
				":CopilotChat ",
				desc = "Quick ask Copilot (type after)",
			},

			-- direct buffer chat
			{
				"<leader>cb",
				":CopilotChat #buffer ",
				desc = "Direct buffer chat command",
			},

			-- Accept Copilot suggestion
			{ "M-a", "<cmd>Copilot#Accept()<cr>", desc = "Accept Copilot suggestion", expr = true, silent = true },

			-- Reject Copilot suggestion
			{ "M-d", "<cmd>Copilot#Reject()<cr>", desc = "Reject Copilot suggestion", expr = true, silent = true },

			-- Copilot toggle commands
			{
				"<leader>cd",
				"<cmd>Copilot disable<cr>",
				desc = "Disable Copilot",
			},
			{
				"<leader>ce",
				"<cmd>Copilot enable<cr>",
				desc = "Enable Copilot",
			},
		},
	},
}
