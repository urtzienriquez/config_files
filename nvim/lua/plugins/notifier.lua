-- nvim/lua/plugins/notify.lua (replaces snacks.notifier)
return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            background_colour = "#000000",
            timeout = 3000,
            stages = "static",
            render = "wrapped-compact",
		})
		vim.notify = notify
	end,
}
