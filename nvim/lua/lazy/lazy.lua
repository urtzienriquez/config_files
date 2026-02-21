local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	dev = {
		path = "~/Documents/GitHub",
	},
	change_detection = {
		notify = false,
	},
	spec = {
		{ import = "plugins" },
	},
	checker = { enabled = true },
	ui = { backdrop = 40 },

    -- hack until a better fix to remove border around backdrop
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User: fix backdrop for lazy window",
		pattern = "lazy_backdrop",
		group = vim.api.nvim_create_augroup("lazynvim-fix", { clear = true }),
		callback = function(ctx)
			local win = vim.fn.win_findbuf(ctx.buf)[1]
			vim.api.nvim_win_set_config(win, { border = "none" })
		end,
	}),
})
