-- lua/color-chameleon/lib/auto_commands.lua
-- Autocommand setup for color-chameleon

local AutoCommands = {}

--- Setup the autocommands
function AutoCommands.setup()
	local config = require("color-chameleon.config").get()
	local Chameleon = require("color-chameleon.chameleon")

	-- Check if enabled
	if not config or not config.enabled then
		return
	end

	-- Validate configuration
	if not config.rules or #config.rules == 0 then
		vim.notify("color-chameleon: No rules configured", vim.log.levels.WARN)
		return
	end

	-- Setup autocmd
	vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
		callback = function()
			Chameleon.scan_surroundings(config)
		end,
		desc = "Update colorscheme based on directory rules",
	})

	-- Check on startup
	Chameleon.scan_surroundings(config)
end

return AutoCommands
