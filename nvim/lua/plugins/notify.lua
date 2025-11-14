return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            background_colour = "#000000",
            timeout = 3000,
            stages = "static",
            render = "wrapped-compact",
            max_width = 40
		})
		vim.notify = notify
	end,
}
