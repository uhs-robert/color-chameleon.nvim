-- lua/color-chameleon/api.lua
-- Provides user-facing API commands for ColorChameleon

local Api = {}

--- Setup API commands
---@param ColorChameleon table The main plugin module
function Api.setup(ColorChameleon)
	-- Command to enable camouflage mode
	vim.api.nvim_create_user_command("ChameleonEnable", function()
		local AutoCommands = require("color-chameleon.lib.auto_commands")
		AutoCommands.setup()
		vim.notify("Color Chameleon: Camouflage enabled", vim.log.levels.INFO)
	end, {
		desc = "Enable ColorChameleon automatic colorscheme switching",
	})

	-- Command to disable camouflage mode
	vim.api.nvim_create_user_command("ChameleonDisable", function()
		-- TODO: Implement disable functionality in camouflage.lua, or do we just remove the auto_commands setup in auto_commands.lua?
		vim.notify("Color Chameleon: Camouflage disabled", vim.log.levels.INFO)
	end, {
		desc = "Disable ColorChameleon automatic colorscheme switching",
	})

	-- Command to show current status
	vim.api.nvim_create_user_command("ChameleonStatus", function()
		local Chameleon = require("color-chameleon.chameleon")
		local lines = Chameleon.get_status()
		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
	end, {
		desc = "Show ColorChameleon status and configuration",
	})

	-- Command to show env variables
	vim.api.nvim_create_user_command("ChameleonEnv", function()
		local env = vim.fn.environ()
		local env_vars = {}

		for k, v in pairs(env) do
			table.insert(env_vars, string.format("%s = %s", k, tostring(v)))
		end
		table.sort(env_vars)

		if #env_vars == 0 then
			vim.notify("No environment variables found", vim.log.levels.WARN)
			return
		end

		vim.notify(table.concat(env_vars, "\n"), vim.log.levels.INFO, { title = "Environment Variables" })
	end, { desc = "Show all environment variables" })

	-- Expose lua API functions
	ColorChameleon.enable = function()
		vim.cmd("ChameleonEnable")
	end

	ColorChameleon.disable = function()
		vim.cmd("ChameleonDisable")
	end

	ColorChameleon.status = function()
		vim.cmd("ChameleonStatus")
	end

	ColorChameleon.env = function()
		vim.cmd("ChameleonEnv")
	end
end

return Api
