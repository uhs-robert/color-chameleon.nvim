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

--- Log a debug message to the provided messages table
---@param messages table|nil Array to collect messages (if nil, message is ignored)
---@param message string The message to log
function Debug.log(messages, message)
	if not messages then
		return
	end
	table.insert(messages, message)
end

--- Flush collected debug messages as a single notification
---@param messages table Array of messages to flush
function Debug.flush(messages)
	if not messages or #messages == 0 then
		return
	end

	local config = require("color-chameleon.config").get()
	if not config or not config.debug then
		return
	end

	vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO, { title = "ColorChameleon" })
end

--- Log rule evaluation details
---@param messages table|nil Array to collect messages (if nil, logging is skipped)
---@param rule table The rule being evaluated
---@param rule_index number The rule index
---@param matched boolean Whether the rule matched
---@param current_dir string The current directory
---@param bufnr number Buffer number being checked
function Debug.log_rule_evaluation(messages, rule, rule_index, matched, current_dir, bufnr)
	if not messages then
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
		table.insert(
			parts,
			string.format("  filetype: %s (current: %s)", format_value(rule.filetype), vim.bo[bufnr].filetype)
		)
	end
	if rule.buftype then
		table.insert(
			parts,
			string.format("  buftype: %s (current: %s)", format_value(rule.buftype), vim.bo[bufnr].buftype)
		)
	end
	if rule.condition then
		table.insert(parts, "  condition: <function>")
	end
	table.insert(parts, string.format("  colorscheme: %s", rule.colorscheme))
	table.insert(parts, string.format("  current_dir: %s", current_dir))

	for _, line in ipairs(parts) do
		table.insert(messages, line)
	end
end

--- Log colorscheme change
---@param messages table|nil Array to collect messages (if nil, logging is skipped)
---@param from string|nil Previous colorscheme
---@param to string New colorscheme
---@param reason string Reason for the change
function Debug.log_colorscheme_change(messages, from, to, reason)
	if not messages then
		return
	end
	local message = string.format("Colorscheme: %s → %s (%s)", from or "none", to, reason)
	Debug.log(messages, message)
end

--- Get inspection report for current buffer and rule matching
---@return table lines Array of formatted status lines
function Debug.get_inspection_report()
	local Rules = require("color-chameleon.lib.rules")
	local Directory = require("color-chameleon.lib.directory")
	local config = require("color-chameleon.config").get()

	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local win_config = vim.api.nvim_win_get_config(win)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local basename = vim.fn.fnamemodify(bufname, ":t")
	local bo = vim.bo[bufnr]
	local current_dir = Directory.get_effective()

	local lines = {
		"ColorChameleon Inspector",
		"",
		"=== Buffer Info ===",
		string.format("Buffer: %d", bufnr),
		string.format("Name: %s", bufname ~= "" and bufname or "(empty)"),
		string.format("Basename: %s", basename ~= "" and basename or "(empty)"),
		string.format("Filetype: %s", bo.filetype ~= "" and bo.filetype or "(empty)"),
		string.format("Buftype: %s", bo.buftype ~= "" and bo.buftype or "(empty)"),
		"",
		"=== Buffer Properties ===",
		string.format("buflisted: %s", tostring(bo.buflisted)),
		string.format("modifiable: %s", tostring(bo.modifiable)),
		string.format("readonly: %s", tostring(bo.readonly)),
		string.format("bufhidden: %s", bo.bufhidden ~= "" and bo.bufhidden or "(empty)"),
		"",
		"=== Window Info ===",
		string.format("Window: %d", win),
		string.format("Floating: %s", win_config.relative ~= "" and "YES" or "NO"),
		"",
		"=== Directory ===",
		string.format("Current: %s", current_dir or "(unable to determine)"),
		"",
		"=== Rule Matching ===",
	}

	if not current_dir then
		table.insert(lines, "Cannot evaluate rules (no effective directory)")
		return lines
	end

	local matching_rule = Rules.find_matching(config.rules, bufnr, nil)

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
		if config.default then
			table.insert(lines, "")
			table.insert(lines, "Default colorscheme: " .. config.default)
		end
	end

	return lines
end

return Debug
