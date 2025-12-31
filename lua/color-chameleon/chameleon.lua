-- lua/color-chameleon/chameleon.lua
-- Chameleon state management for colorscheme switching

local Chameleon = {}

-- Camouflage state
local CAMO = {
	active_rule = nil,
	prev_colorscheme = nil,
}

--- Reset camouflage state and optionally restore colorscheme
---@param default string|nil Colorscheme to restore to (nil = previous)
---@param background string|nil Optional background setting ("light" or "dark")
function Chameleon.reset(default, background)
	local Theme = require("color-chameleon.lib.theme")
	local restore_to = default or CAMO.prev_colorscheme

	if restore_to then
		Theme.set(restore_to, background)
	end

	CAMO.active_rule = nil
	CAMO.prev_colorscheme = nil
end

--- Blend into environment by applying colorscheme based on matching rule
---@param matching_rule table|nil
---@param default_theme table|nil Default theme table with colorscheme and background
local function blend_in(matching_rule, default_theme)
	local Theme = require("color-chameleon.lib.theme")
	local current_colorscheme = vim.g.colors_name
	default_theme = default_theme or {}

	-- Entering a directory with matching rule
	if matching_rule and not CAMO.active_rule then
		CAMO.prev_colorscheme = current_colorscheme
		CAMO.active_rule = matching_rule
		Theme.set(matching_rule.colorscheme, matching_rule.background)

	-- Switching between different matching rules
	elseif matching_rule and CAMO.active_rule and matching_rule ~= CAMO.active_rule then
		CAMO.active_rule = matching_rule
		Theme.set(matching_rule.colorscheme, matching_rule.background)

	-- Leaving directory with matching rule
	elseif not matching_rule and CAMO.active_rule then
		local restore_to = default_theme.colorscheme or CAMO.prev_colorscheme
		local restore_bg = default_theme.background
		CAMO.active_rule = nil
		CAMO.prev_colorscheme = nil

		if restore_to then
			Theme.set(restore_to, restore_bg)
		end
	end
end

--- Scan surroundings and adapt colorscheme to match environment
---@param config table
---@param bufnr number|nil Buffer number to check (defaults to current buffer)
function Chameleon.scan_surroundings(config, bufnr)
	config = config or require("color-chameleon.config").get()
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not config or not config.enabled then
		return
	end
	local debug_messages = config.debug and {} or nil

	-- Skip floating windows immediately to avoid infinite loops from debug notifications
	local win = vim.api.nvim_get_current_win()
	local win_config = vim.api.nvim_win_get_config(win)
	if win_config.relative ~= "" then
		return -- Skip silently, no logging to avoid notification loops
	end

	-- Skip UI buffers and side panels
	local Buffer = require("color-chameleon.lib.buffer")
	local should_skip, skip_reason = Buffer.should_skip(config.rules, bufnr)
	if should_skip then
		if skip_reason and debug_messages then
			local Debug = require("color-chameleon.lib.debug")
			Debug.log(debug_messages, string.format("Skipping: %s", skip_reason))
			Debug.flush(debug_messages)
		end
		return
	end

	local Directory = require("color-chameleon.lib.directory")
	if not Directory.get_effective() then
		return
	end

	local Rules = require("color-chameleon.lib.rules")
	local matching_rule = Rules.find_matching(config.rules, bufnr, debug_messages)
	blend_in(matching_rule, config.default)

	-- Flush debug messages at the end of evaluation
	if debug_messages then
		local Debug = require("color-chameleon.lib.debug")
		Debug.flush(debug_messages)
	end
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

		-- Show active rule if any
		if CAMO.active_rule then
			table.insert(lines, "Active rule: matching")
			table.insert(lines, "  Previous colorscheme: " .. (CAMO.prev_colorscheme or "none"))
		else
			table.insert(lines, "Active rule: none")
		end

		table.insert(lines, "")
		table.insert(lines, "Rules:")
		for i, rule in ipairs(config.rules or {}) do
			local is_active = rule == CAMO.active_rule
			local prefix = is_active and "  ✓ " or "    "
			local rule_desc = string.format("%s%d. ", prefix, i)

			if rule.path then
				rule_desc = rule_desc .. "path=" .. rule.path .. " "
			end
			if rule.env then
				rule_desc = rule_desc .. "env=" .. vim.inspect(rule.env) .. " "
			end
			if rule.condition then
				rule_desc = rule_desc .. "condition=<function> "
			end
			rule_desc = rule_desc .. "→ " .. rule.colorscheme
			table.insert(lines, rule_desc)
		end

		if config.default and config.default.colorscheme then
			table.insert(lines, "")
			local default_desc = "Default: " .. config.default.colorscheme
			if config.default.background then
				default_desc = default_desc .. " (background: " .. config.default.background .. ")"
			end
			table.insert(lines, default_desc)
		end
	else
		table.insert(lines, "Camouflage: disabled")
	end

	return lines
end

return Chameleon
