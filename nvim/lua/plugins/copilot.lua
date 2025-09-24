return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{
				"github/copilot.vim",
				config = function()
					vim.g.copilot_enabled = false -- Disable Copilot by default
					vim.g.copilot_no_tab_map = true -- Disable default Tab mapping

					vim.keymap.set("i", "<M-a>", 'copilot#Accept("\\<CR>")', {
						expr = true,
						replace_keycodes = false,
					})
					vim.keymap.set("i", "<M-d>", 'copilot#Reject("\\<CR>")', {
						expr = true,
						replace_keycodes = false,
					})
					vim.keymap.set("i", "<M-]>", "copilot#Next()", { expr = true })
					vim.keymap.set("i", "<M-[>", "copilot#Previous()", { expr = true })
					vim.keymap.set("i", "<M-d>", "copilot#Dismiss()", { expr = true })
				end,
			},
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			-- model = "claude-sonnet-4",
			debug = false,
			show_help = true,
			auto_follow_cursor = false,
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")
			opts.selection = select.unnamed
			chat.setup(opts)

			-- Create custom commands with explicit buffer selection
			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, { selection = select.visual })
			end, { nargs = "*", range = true })

			-- Inline chat with Copilot
			vim.api.nvim_create_user_command("CopilotChatInline", function(args)
				chat.ask(args.args, {
					selection = select.visual,
					window = {
						layout = "float",
						relative = "cursor",
						width = 0.8,
						height = 0.4,
						row = 1,
						col = 0,
					},
				})
			end, { nargs = "*", range = true })
		end,
		event = "VeryLazy",
		keys = {
			-- Basic chat commands
			{ "<leader>gc", mode = "n", "<cmd>CopilotChatToggle<cr>", desc = "Toggle CopilotChat" },
			{ "<leader>gm", mode = "n", "<cmd>CopilotChatModel<cr>", desc = "Select Copilot Model" },
			{ "<leader>gx", mode = { "n", "v" }, "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
			{ "<leader>gt", mode = "n", "<cmd>CopilotChatTests<cr>", desc = "Generate tests" },
			{ "<leader>gr", mode = { "n", "v" }, "<cmd>CopilotChatReview<cr>", desc = "Review code" },
			{ "<leader>go", mode = "v", "<cmd>CopilotChatOptimize<cr>", desc = "Optimize code" },
			-- Visual mode chat
			{
				"<leader>gv",
				mode = "x",
				":CopilotChatVisual ",
				desc = "Chat with visual selection",
			},
			-- Quick chat
			{
				"<leader>gq",
				":CopilotChat ",
				desc = "Quick ask Copilot (type after)",
			},
			-- direct buffer chat
			{
				"<leader>gb",
				":CopilotChat #buffer ",
				desc = "Direct buffer chat command",
			},
			-- inline chat
			{
				"<leader>gi",
				mode = "v",
				":CopilotChatInline ",
				desc = "CopilotChat - Inline chat",
			},
			-- Copilot disable
			{
				"<leader>gd",
				"<cmd>Copilot disable<cr>",
				desc = "Disable Copilot",
			},
			-- Copilot enable
			{
				"<leader>ge",
				"<cmd>Copilot enable<cr>",
				desc = "Enable Copilot",
			},
		},
	},
}
