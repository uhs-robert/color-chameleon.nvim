-- lua/color-chameleon/api.lua
-- Provides user-facing API commands for ColorChameleon

local Api = {}

--- Enable camouflage mode
function Api.enable()
	local Config = require("color-chameleon.config")
	local AutoCommands = require("color-chameleon.lib.auto_commands")
	Config.enable()
	AutoCommands.setup()
	vim.notify("Color Chameleon: Camouflage enabled", vim.log.levels.INFO)
end

--- Disable camouflage mode
function Api.disable()
	local Config = require("color-chameleon.config")
	local Chameleon = require("color-chameleon.chameleon")
	local AutoCommands = require("color-chameleon.lib.auto_commands")
	Config.disable()
	AutoCommands.teardown()
	local default = Config.get().default
	Chameleon.reset(default)
	vim.notify("Color Chameleon: Camouflage disabled", vim.log.levels.INFO)
end

--- Toggle camouflage mode
function Api.toggle()
	local Config = require("color-chameleon.config")
	if Config.get().enabled then
		Api.disable()
	else
		Api.enable()
	end
end

--- Show current status
function Api.status()
	local Chameleon = require("color-chameleon.chameleon")
	local lines = Chameleon.get_status()
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Show environment variables
function Api.env()
	local environment = vim.fn.environ()
	local env_vars = {}

	for k, v in pairs(environment) do
		table.insert(env_vars, string.format("%s = %s", k, tostring(v)))
	end
	table.sort(env_vars)

	if #env_vars == 0 then
		vim.notify("No environment variables found", vim.log.levels.WARN)
		return
	end

	vim.notify(table.concat(env_vars, "\n"), vim.log.levels.INFO, { title = "Environment Variables" })
end

--- Reload configuration
---@param user_config table|nil Optional new configuration
function Api.reload(user_config)
	local Config = require("color-chameleon.config")
	Config.reload(user_config)
	vim.notify("Color Chameleon: Configuration reloaded", vim.log.levels.INFO)
end

--- Inspect current buffer and show which rule would match
function Api.inspect()
	local Debug = require("color-chameleon.lib.debug")
	local lines = Debug.get_inspection_report()
	if #lines > 0 then
		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
	end
end

--- Toggle debug mode
function Api.debug()
	local Config = require("color-chameleon.config")
	local config = Config.get()
	config.debug = not config.debug
	local status = config.debug and "enabled" or "disabled"
	vim.notify("Color Chameleon: Debug mode " .. status, vim.log.levels.INFO)
end

--- Setup user commands
function Api.setup()
	vim.api.nvim_create_user_command("ChameleonEnable", Api.enable, {
		desc = "Enable ColorChameleon automatic colorscheme switching",
	})

	vim.api.nvim_create_user_command("ChameleonDisable", Api.disable, {
		desc = "Disable ColorChameleon automatic colorscheme switching",
	})

	vim.api.nvim_create_user_command("ChameleonToggle", Api.toggle, {
		desc = "Toggle ColorChameleon automatic colorscheme switching",
	})

	vim.api.nvim_create_user_command("ChameleonStatus", Api.status, {
		desc = "Show ColorChameleon status and configuration",
	})

	vim.api.nvim_create_user_command("ChameleonEnv", Api.env, {
		desc = "Show all environment variables",
	})

	vim.api.nvim_create_user_command("ChameleonReload", Api.reload, {
		desc = "Reload ColorChameleon configuration",
	})

	vim.api.nvim_create_user_command("ChameleonInspect", Api.inspect, {
		desc = "Inspect current buffer and show which rule would match",
	})

	vim.api.nvim_create_user_command("ChameleonDebug", Api.debug, {
		desc = "Toggle ColorChameleon debug mode",
	})
end

return Api
