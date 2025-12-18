-- lua/color-chameleon/lib/debug.lua
-- Debug utilities for color-chameleon

local Debug = {}

--- Format a value that can be a string or array
---@param value string|string[] The value to format
---@return string formatted The formatted string
local function format_value(value)
	if type(value) == "table" then
		return "[" .. table.concat(value, ", ") .. "]"
	end
	return tostring(value)
end

--- Log a debug message if debug mode is enabled
---@param message string The message to log
---@param level? number The log level (default: INFO)
function Debug.log(message, level)
	local config = require("color-chameleon.config").get()
	if not config or not config.debug then
		return
	end

	level = level or vim.log.levels.INFO
	vim.notify("[ColorChameleon] " .. message, level)
end

--- Log rule evaluation details
---@param rule table The rule being evaluated
---@param rule_index number The rule index
---@param matched boolean Whether the rule matched
---@param current_dir string The current directory
function Debug.log_rule_evaluation(rule, rule_index, matched, current_dir)
	local config = require("color-chameleon.config").get()
	if not config or not config.debug then
		return
	end

	local status = matched and "✓ MATCHED" or "✗ No match"
	local parts = { string.format("Rule %d: %s", rule_index, status) }

	if rule.path then
		table.insert(parts, string.format("  path: %s", format_value(rule.path)))
	end
	if rule.env then
		table.insert(parts, string.format("  env: %s", vim.inspect(rule.env)))
	end
	if rule.filetype then
		table.insert(parts, string.format("  filetype: %s (current: %s)", format_value(rule.filetype), vim.bo.filetype))
	end
	if rule.buftype then
		table.insert(parts, string.format("  buftype: %s (current: %s)", format_value(rule.buftype), vim.bo.buftype))
	end
	if rule.condition then
		table.insert(parts, "  condition: <function>")
	end
	table.insert(parts, string.format("  colorscheme: %s", rule.colorscheme))
	table.insert(parts, string.format("  current_dir: %s", current_dir))

	Debug.log(table.concat(parts, "\n"))
end

--- Log colorscheme change
---@param from string|nil Previous colorscheme
---@param to string New colorscheme
---@param reason string Reason for the change
function Debug.log_colorscheme_change(from, to, reason)
	local config = require("color-chameleon.config").get()
	if not config or not config.debug then
		return
	end

	local message = string.format("Colorscheme: %s → %s (%s)", from or "none", to, reason)
	Debug.log(message)
end

--- Test which rule would match in the current context
---@return table lines Array of formatted status lines
function Debug.test_rules()
	local Config = require("color-chameleon.config")
	local Rules = require("color-chameleon.lib.rules")
	local Directory = require("color-chameleon.lib.directory")

	local config = Config.get()
	local current_dir = Directory.get_effective()

	if not current_dir then
		vim.notify("No effective directory (special buffer type)", vim.log.levels.WARN)
		return {}
	end

	local lines = {
		"ColorChameleon Rule Test",
		"",
		"Current directory: " .. current_dir,
		"",
	}

	local matching_rule = Rules.find_matching(config.rules)

	if matching_rule then
		table.insert(lines, "✓ MATCHING RULE FOUND:")
		table.insert(lines, "")
		if matching_rule.path then
			table.insert(lines, "  Path: " .. format_value(matching_rule.path))
		end
		if matching_rule.env then
			table.insert(lines, "  Env: " .. vim.inspect(matching_rule.env))
		end
		if matching_rule.filetype then
			table.insert(lines, "  Filetype: " .. format_value(matching_rule.filetype))
		end
		if matching_rule.buftype then
			table.insert(lines, "  Buftype: " .. format_value(matching_rule.buftype))
		end
		if matching_rule.condition then
			table.insert(lines, "  Condition: <function>")
		end
		table.insert(lines, "  Colorscheme: " .. matching_rule.colorscheme)
	else
		table.insert(lines, "✗ NO MATCHING RULE")
		if config.fallback then
			table.insert(lines, "")
			table.insert(lines, "Fallback colorscheme: " .. config.fallback)
		end
	end

	return lines
end

return Debug
