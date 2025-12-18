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
	if rule.path and type(rule.path) ~= "string" then
		return false, string.format("Rule %d: 'path' must be a string", index)
	end

	if rule.env and type(rule.env) ~= "table" then
		return false, string.format("Rule %d: 'env' must be a table", index)
	end

	if rule.condition and type(rule.condition) ~= "function" then
		return false, string.format("Rule %d: 'condition' must be a function", index)
	end

	if rule.filetype and type(rule.filetype) ~= "string" then
		return false, string.format("Rule %d: 'filetype' must be a string", index)
	end

	if rule.buftype and type(rule.buftype) ~= "string" then
		return false, string.format("Rule %d: 'buftype' must be a string", index)
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
