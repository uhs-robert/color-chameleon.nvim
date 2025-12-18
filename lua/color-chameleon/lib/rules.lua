-- lua/color-chameleon/lib/rules.lua
-- Rule matching logic

local Rules = {}

--- Check if environment variable matches expected value
---@param env_value string|nil Actual environment variable value
---@param expected any Expected value (true/false/string)
---@return boolean
local function env_matches(env_value, expected)
	if expected == true then
		return env_value ~= nil
	elseif expected == false then
		return env_value == nil
	else
		return env_value == expected
	end
end

--- Check if all environment variable conditions match
---@param env_conditions table|nil
---@return boolean
local function check_env_conditions(env_conditions)
	if not env_conditions then
		return true
	end

	for env_var, expected in pairs(env_conditions) do
		if not env_matches(vim.env[env_var], expected) then
			return false
		end
	end

	return true
end

--- Check if path condition matches
---@param rule_path string|nil
---@param current_dir string
---@return boolean
local function path_matches(rule_path, current_dir)
	local Directory = require("color-chameleon.lib.directory")
	if not rule_path then
		return true
	end

	local resolved_path = Directory.realpath(rule_path)
	if not resolved_path then
		return false
	end

	-- Exact match or prefix match with directory separator
	return current_dir == resolved_path or current_dir:sub(1, #resolved_path + 1) == resolved_path .. "/"
end

--- Check if custom condition function passes
---@param condition function|nil
---@param current_dir string
---@return boolean
local function custom_condition_matches(condition, current_dir)
	if not condition or type(condition) ~= "function" then
		return true
	end

	local success, result = pcall(condition, current_dir)
	return success and result
end

--- Check if buffer property matches
---@param rule_value string|nil Expected buffer property value
---@param actual_value string Actual buffer property value
---@return boolean
local function buffer_property_matches(rule_value, actual_value)
	if not rule_value then
		return true
	end
	return rule_value == actual_value
end

--- Check if all buffer conditions match
---@param rule table
---@return boolean
local function check_buffer_conditions(rule)
	if not rule.filetype and not rule.buftype then
		return true
	end

	local current_filetype = vim.bo.filetype
	local current_buftype = vim.bo.buftype

	return buffer_property_matches(rule.filetype, current_filetype)
		and buffer_property_matches(rule.buftype, current_buftype)
end

--- Check if a rule matches all conditions
---@param rule table
---@param current_dir string
---@return boolean
local function rule_matches(rule, current_dir)
	return path_matches(rule.path, current_dir)
		and check_env_conditions(rule.env)
		and custom_condition_matches(rule.condition, current_dir)
		and check_buffer_conditions(rule)
end

--- Find matching rule for current working directory
---@param rules table[]
---@return table|nil
function Rules.find_matching(rules)
	local Directory = require("color-chameleon.lib.directory")
	local Debug = require("color-chameleon.lib.debug")
	local current_dir = Directory.get_effective()
	if not current_dir then
		Debug.log("No effective directory found (special buffer type)")
		return nil
	end

	Debug.log(string.format("Evaluating %d rules for directory: %s", #rules, current_dir))

	for i, rule in ipairs(rules) do
		local matched = rule_matches(rule, current_dir)
		Debug.log_rule_evaluation(rule, i, matched, current_dir)

		if matched then
			Debug.log(string.format("✓ Rule %d matched, applying colorscheme: %s", i, rule.colorscheme))
			return rule
		end
	end

	Debug.log("No matching rules found")
	return nil
end

return Rules
