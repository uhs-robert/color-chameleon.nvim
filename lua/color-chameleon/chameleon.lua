-- lua/color-chameleon/chameleon.lua
-- Chameleon state management for colorscheme switching

local Chameleon = {}

-- Camouflage state
local CAMO = {
	active_rule = nil,
	prev_colorscheme = nil,
}

--- Blend into environment by applying colorscheme based on matching rule
---@param matching_rule table|nil
---@param fallback string|nil
local function blend_in(matching_rule, fallback)
	local Theme = require("color-chameleon.lib.theme")
	local current_colorscheme = vim.g.colors_name

	-- Entering a directory with matching rule
	if matching_rule and not CAMO.active_rule then
		CAMO.prev_colorscheme = current_colorscheme
		CAMO.active_rule = matching_rule
		Theme.set(matching_rule.colorscheme)

	-- Switching between different matching rules
	elseif matching_rule and CAMO.active_rule and matching_rule ~= CAMO.active_rule then
		CAMO.active_rule = matching_rule
		Theme.set(matching_rule.colorscheme)

	-- Leaving directory with matching rule
	elseif not matching_rule and CAMO.active_rule then
		local restore_to = fallback or CAMO.prev_colorscheme
		CAMO.active_rule = nil
		CAMO.prev_colorscheme = nil

		if restore_to then
			Theme.set(restore_to)
		end
	end
end

--- Scan surroundings and adapt colorscheme to match environment
---@param config table
function Chameleon.scan_surroundings(config)
	local Directory = require("color-chameleon.lib.directory")
	if not Directory.get_effective() then
		return
	end

	local Rules = require("color-chameleon.lib.rules")
	local matching_rule = Rules.find_matching(config.rules)
	blend_in(matching_rule, config.fallback)
end

--- Get status information for ColorChameleon
---@return table lines Array of status lines
function Chameleon.get_status()
	local config = require("color-chameleon.config").get()
	local current_colorscheme = vim.g.colors_name or "none"

	local lines = {
		"Color Chameleon Status",
		"",
		"Current colorscheme: " .. current_colorscheme,
	}

	if config and config.enabled then
		table.insert(lines, "Camouflage: enabled")
		table.insert(lines, "")
		table.insert(lines, "Rules:")
		for i, rule in ipairs(config.rules or {}) do
			local rule_desc = string.format("  %d. ", i)
			if rule.path then
				rule_desc = rule_desc .. "path=" .. rule.path .. " "
			end
			if rule.env then
				rule_desc = rule_desc .. "env=" .. vim.inspect(rule.env) .. " "
			end
			rule_desc = rule_desc .. "→ " .. rule.colorscheme
			table.insert(lines, rule_desc)
		end
	else
		table.insert(lines, "Camouflage: disabled")
	end

	return lines
end

return Chameleon
