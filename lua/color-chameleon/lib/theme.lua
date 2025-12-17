-- lua/color-chameleon/lib/theme.lua
-- Colorscheme management utilities

local Theme = {}

--- Apply a colorscheme safely with error handling
---@param colorscheme string The name of the colorscheme to apply
---@return boolean success Whether the colorscheme was applied successfully
function Theme.apply(colorscheme)
	if not colorscheme or colorscheme == "" then
		vim.notify("ColorChameleon: No colorscheme specified", vim.log.levels.WARN)
		return false
	end

	-- Don't reapply if already active
	if vim.g.colors_name == colorscheme then
		return true
	end

	local success, err = pcall(vim.cmd.colorscheme, colorscheme)
	if not success then
		vim.notify(
			string.format("ColorChameleon: Failed to apply colorscheme '%s': %s", colorscheme, err),
			vim.log.levels.ERROR
		)
		return false
	end

	return true
end

--- Set colorscheme silently (idempotent, no notifications)
---@param name string The name of the colorscheme to apply
function Theme.set(name)
	if not name or name == "" or vim.g.colors_name == name then
		return
	end
	pcall(vim.cmd.colorscheme, name)
end

--- Get the currently active colorscheme
---@return string|nil current The name of the current colorscheme, or nil if none is set
function Theme.get_current()
	return vim.g.colors_name
end

--- Check if a colorscheme is available
---@param colorscheme string The name of the colorscheme to check
---@return boolean available Whether the colorscheme is available
function Theme.is_available(colorscheme)
	local path = vim.api.nvim_get_runtime_file("colors/" .. colorscheme .. ".{vim,lua}", false)
	return #path > 0
end

--- Get a list of all available colorschemes
---@return table colorschemes List of available colorscheme names
function Theme.get_available()
	local colorschemes = {}
	local runtime_files = vim.api.nvim_get_runtime_file("colors/*.{vim,lua}", true)

	for _, file in ipairs(runtime_files) do
		local name = vim.fn.fnamemodify(file, ":t:r")
		if not vim.tbl_contains(colorschemes, name) then
			table.insert(colorschemes, name)
		end
	end

	table.sort(colorschemes)
	return colorschemes
end

--- Store the current colorscheme to restore later
---@return string|nil stored The stored colorscheme name
function Theme.store_current()
	local current = Theme.get_current()
	if current then
		vim.g.color_chameleon_stored_theme = current
	end
	return current
end

--- Restore a previously stored colorscheme
---@return boolean success Whether restoration was successful
function Theme.restore_stored()
	local stored = vim.g.color_chameleon_stored_theme
	if stored then
		return Theme.apply(stored)
	end
	return false
end

return Theme
