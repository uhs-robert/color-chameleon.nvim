-- lua/color-chameleon/health.lua
-- Health check module for :checkhealth color-chameleon

local M = {}

-- Use vim.health if available (Neovim 0.10+), otherwise fall back to health module
local health = vim.health or require("health")

function M.check()
	health.start("color-chameleon.nvim")

	local Config = require("color-chameleon.config")
	local Validate = require("color-chameleon.lib.validate")
	local config = Config.get()

	-- Check if plugin is enabled
	if config.enabled then
		health.ok("Plugin is enabled")
	else
		health.info("Plugin is disabled (set enabled = true to activate)")
	end

	-- Check rules configuration
	if not config.rules or #config.rules == 0 then
		health.warn("No rules configured", {
			"Add rules to your setup() call",
			"See :help color-chameleon for examples",
		})
	else
		health.ok(string.format("Found %d rule(s)", #config.rules))

		-- Check each rule's colorscheme availability
		local missing_colorschemes = {}
		for i, rule in ipairs(config.rules) do
			if rule.colorscheme then
				if not Validate.colorscheme(rule.colorscheme) then
					table.insert(
						missing_colorschemes,
						string.format("Rule %d: '%s' not found", i, rule.colorscheme)
					)
				end
			end
		end

		if #missing_colorschemes > 0 then
			health.warn("Some colorschemes in rules are not available", missing_colorschemes)
		else
			health.ok("All rule colorschemes are available")
		end
	end

	-- Check fallback colorscheme
	if config.fallback then
		if type(config.fallback) == "string" then
			if Validate.colorscheme(config.fallback) then
				health.ok(string.format("Fallback colorscheme '%s' is available", config.fallback))
			else
				health.error(
					string.format("Fallback colorscheme '%s' not found", config.fallback),
					{
						"Install the colorscheme or change the fallback option",
						"Set fallback = nil to restore previous colorscheme instead",
					}
				)
			end
		else
			health.error("Fallback must be a string or nil")
		end
	else
		health.info("No fallback colorscheme configured (will restore previous colorscheme)")
	end

	-- Check current state
	local Chameleon = require("color-chameleon.chameleon")
	local status = Chameleon.get_status()

	if status.active_rule then
		health.info(
			string.format(
				"Currently using colorscheme '%s' (matched rule)",
				status.active_rule.colorscheme
			)
		)
	else
		health.info("No active rule (using default colorscheme)")
	end
end

return M
