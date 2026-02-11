return {
	"tpope/vim-fugitive",
	lazy = false,
	config = function()
		local My_Fugitive = vim.api.nvim_create_augroup("My_Fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = My_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "aa", function()
					vim.cmd.Git("add -A")
				end, opts)
			end,
		})
		-- Set up keymaps
		vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
		vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
		vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })
		vim.keymap.set("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git push" })
		vim.keymap.set("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git pull" })
		vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit<cr>", { desc = "Git diff split" })
		vim.keymap.set("n", "<leader>gB", "<cmd>Git blame<cr>", { desc = "Git blame" })
		vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage current file)" })
		vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout current file)" })
	end,
}
