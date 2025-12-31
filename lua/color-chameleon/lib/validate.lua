-- lua/color-chameleon/lib/validate.lua
-- Configuration validation utilities

local Validate = {}

--- Check if a colorscheme is available
---@param colorscheme string The name of the colorscheme to check
---@return boolean available Whether the colorscheme is available
function Validate.colorscheme(colorscheme)
	if not colorscheme or colorscheme == "" then
		return false
	end

	local path = vim.api.nvim_get_runtime_file("colors/" .. colorscheme .. ".{vim,lua}", false)
	return #path > 0
end

--- Validate a field that can be a string or array of strings
---@param value any The value to validate
---@param field_name string The field name for error messages
---@param rule_index number The rule index for error messages
---@return boolean valid Whether the value is valid
---@return string|nil error_message Error message if invalid
local function validate_string_or_array(value, field_name, rule_index)
	if type(value) == "string" then
		return true, nil
	end

	if type(value) == "table" then
		if #value == 0 then
			return false, string.format("Rule %d: '%s' array cannot be empty", rule_index, field_name)
		end
		for i, v in ipairs(value) do
			if type(v) ~= "string" then
				return false,
					string.format("Rule %d: '%s[%d]' must be a string, got %s", rule_index, field_name, i, type(v))
			end
		end
		return true, nil
	end

	return false, string.format("Rule %d: '%s' must be a string or array of strings", rule_index, field_name)
end

--- Validate a single rule structure
---@param rule table The rule to validate
---@param index number The rule index (for error messages)
---@return boolean valid Whether the rule is valid
---@return string|nil error_message Error message if invalid
function Validate.rule(rule, index)
	if type(rule) ~= "table" then
		return false, string.format("Rule %d is not a table", index)
	end

	-- Check required field: colorscheme
	if not rule.colorscheme then
		return false, string.format("Rule %d missing required field 'colorscheme'", index)
	end

	if type(rule.colorscheme) ~= "string" or rule.colorscheme == "" then
		return false, string.format("Rule %d has invalid colorscheme (must be non-empty string)", index)
	end

	-- Validate optional fields
	if rule.background then
		if type(rule.background) ~= "string" then
			return false, string.format("Rule %d: 'background' must be a string", index)
		end
		if rule.background ~= "light" and rule.background ~= "dark" then
			return false, string.format("Rule %d: 'background' must be either 'light' or 'dark'", index)
		end
	end
	if rule.path then
		local valid, err = validate_string_or_array(rule.path, "path", index)
		if not valid then
			return false, err
		end
	end

	if rule.env and type(rule.env) ~= "table" then
		return false, string.format("Rule %d: 'env' must be a table", index)
	end

	if rule.condition and type(rule.condition) ~= "function" then
		return false, string.format("Rule %d: 'condition' must be a function", index)
	end

	if rule.filetype then
		local valid, err = validate_string_or_array(rule.filetype, "filetype", index)
		if not valid then
			return false, err
		end
	end

	if rule.buftype then
		local valid, err = validate_string_or_array(rule.buftype, "buftype", index)
		if not valid then
			return false, err
		end
	end

	return true, nil
end

--- Validate all rules structure
---@param rules table[] Array of rules to validate
---@return boolean valid Whether all rules are valid
---@return table errors Array of error messages
function Validate.all_rules(rules)
	if type(rules) ~= "table" then
		return false, { "Rules must be a table" }
	end

	local errors = {}

	for i, rule in ipairs(rules) do
		local valid, err = Validate.rule(rule, i)
		if not valid then
			table.insert(errors, err)
		end
	end

	return #errors == 0, errors
end

return Validate
