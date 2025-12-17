-- lua/color-chameleon/lib/auto_commands.lua
-- Autocommand setup for color-chameleon

local AutoCommands = {}
local AUGROUP_ID = nil

--- Setup the autocommands
function AutoCommands.setup()
	local config = require("color-chameleon.config").get()

	-- Check if enabled
	if not config or not config.enabled then
		return
	end

	-- Validate configuration
	if not config.rules or #config.rules == 0 then
		vim.notify("color-chameleon: No rules configured", vim.log.levels.WARN)
		return
	end

	-- Clear existing/create new autocmd group
	if AUGROUP_ID then
		vim.api.nvim_clear_autocmds({ group = AUGROUP_ID })
	end
	AUGROUP_ID = vim.api.nvim_create_augroup("ColorChameleonAutoCommands", { clear = true })

	-- Setup autocmd
	local Chameleon = require("color-chameleon.chameleon")
	vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
		group = AUGROUP_ID,
		callback = function()
			Chameleon.scan_surroundings(config)
		end,
		desc = "Update colorscheme based on directory rules",
	})

	-- Check on startup
	Chameleon.scan_surroundings(config)
end

--- Teardown the autocommands
function AutoCommands.teardown()
	if AUGROUP_ID then
		vim.api.nvim_clear_autocmds({ group = AUGROUP_ID })
		vim.api.nvim_del_augroup_by_id(AUGROUP_ID)
		AUGROUP_ID = nil
	end
end

return AutoCommands
