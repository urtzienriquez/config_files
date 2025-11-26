return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signcolumn = true,
		numhl = false,
		linehl = true, -- Enable line highlighting
		word_diff = true,
		watch_gitdir = {
			follow_files = true,
		},
		attach_to_untracked = false,
		current_line_blame = false, -- Toggle with <leader>gb
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol",
			delay = 500,
			ignore_whitespace = false,
		},
		current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
		sign_priority = 6,
		update_debounce = 100,
		status_formatter = nil,
		max_file_length = 40000,
		preview_config = {
			border = "single",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]c", function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gs.next_hunk()
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Next git hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.prev_hunk()
				end)
				return "<Ignore>"
			end, { expr = true, desc = "Previous git hunk" })

			-- Actions
			map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
			map("v", "<leader>gs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage hunk (visual)" })
			map("v", "<leader>gr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Reset hunk (visual)" })
			map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
			map("n", "<leader>gB", function()
				gs.toggle_current_line_blame()
			end, { desc = "Toggle git blame" })
			map("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, { desc = "Show full git blame" })
			map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
			map("n", "<leader>gD", function()
				gs.diffthis("~")
			end, { desc = "Diff this ~" })

			-- Text object
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
		end,
	},
}
