-- lua/color-chameleon/lib/theme.lua
-- Colorscheme management utilities

local Theme = {}

--- Set colorscheme silently (idempotent, no notifications)
---@param name string The name of the colorscheme to apply
function Theme.set(name)
	if not name or name == "" or vim.g.colors_name == name then
		return
	end
	pcall(vim.cmd.colorscheme, name)
end

return Theme
