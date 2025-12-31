-- lua/color-chameleon/lib/theme.lua
-- Colorscheme management utilities

local Theme = {}

--- Set colorscheme silently (idempotent, no notifications)
---@param name string The name of the colorscheme to apply
---@param background string|nil Optional background setting ("light" or "dark")
function Theme.set(name, background)
	-- Apply background before colorscheme if provided
	if background and (background == "light" or background == "dark") then
		vim.o.background = background
	end

	if not name or name == "" or vim.g.colors_name == name then
		return
	end
	pcall(vim.cmd.colorscheme, name)
end

return Theme
