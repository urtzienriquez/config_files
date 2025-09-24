-- Simple vim-slime configuration
-- Add this as lua/plugins/slime.lua
return {
	"jpalardy/vim-slime",
	config = function()
		-- Use tmux as the target
		vim.g.slime_target = "tmux"
		
		-- Default to sending to the last pane (most common use case)
		vim.g.slime_default_config = {
			socket_name = "default",
			target_pane = "{last}"
		}
		
		-- Don't ask for confirmation each time
		vim.g.slime_dont_ask_default = 1
		
		-- Disable default mappings (we'll set our own in keymaps.lua)
		vim.g.slime_no_mappings = 1
	end,
}
