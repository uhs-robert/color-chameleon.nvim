-- lua/color-chameleon/lib/auto_commands.lua
-- Autocommand setup for color-chameleon

local AutoCommands = {}
local AUGROUP_ID = nil
local GROUP_NAME = "ColorChameleonAutoCommands"

--- Remove augroup safely by id or name
local function delete_group()
	-- Clear by id
	local id = AUGROUP_ID
	if id then
		pcall(vim.api.nvim_clear_autocmds, { group = id })
		pcall(vim.api.nvim_del_augroup_by_id, id)
	end
	AUGROUP_ID = nil

	-- Also clear by name to catch any stale groups
	pcall(vim.api.nvim_clear_autocmds, { group = GROUP_NAME })
	pcall(vim.api.nvim_del_augroup_by_name, GROUP_NAME)
end

--- Setup the autocommands
function AutoCommands.setup()
	local config = require("color-chameleon.config").get()

	if not config or not config.enabled then
		return
	end

	if not config.rules or #config.rules == 0 then
		vim.notify("color-chameleon: No rules configured", vim.log.levels.WARN)
		return
	end

	-- Clear existing/create new autocmd group
	delete_group()
	AUGROUP_ID = vim.api.nvim_create_augroup(GROUP_NAME, { clear = true })

	-- Setup autocmd
	local Chameleon = require("color-chameleon.chameleon")
	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged", "BufReadPost", "BufNewFile", "BufEnter", "TermOpen" }, {
		group = AUGROUP_ID,
		callback = function(event)
			local current_config = require("color-chameleon.config").get()
			Chameleon.scan_surroundings(current_config, event.buf)
		end,
		desc = "Update colorscheme based on directory and buffer rules",
	})

	-- Check immediately if not during startup
	if vim.v.vim_did_enter == 1 then
		Chameleon.scan_surroundings(config)
	end
end

--- Teardown the autocommands
function AutoCommands.teardown()
	delete_group()
end

return AutoCommands
