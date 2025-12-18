-- lua/color-chameleon/lib/rules.lua
-- Rule matching logic

local Directory = require("color-chameleon.lib.directory")

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

--- Check if a rule matches all conditions
---@param rule table
---@param current_dir string
---@return boolean
local function rule_matches(rule, current_dir)
	return path_matches(rule.path, current_dir)
		and check_env_conditions(rule.env)
		and custom_condition_matches(rule.condition, current_dir)
end

--- Find matching rule for current working directory
---@param rules table[]
---@return table|nil
function Rules.find_matching(rules)
	local current_dir = Directory.get_effective()
	if not current_dir then
		return nil
	end

	for i, rule in ipairs(rules) do
		local matched = rule_matches(rule, current_dir)

		if matched then
			return rule
		end
	end

	return nil
end

return Rules
