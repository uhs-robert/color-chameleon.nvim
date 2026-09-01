-- lua/color-chameleon/lib/theme.lua
-- Colorscheme management utilities

local Theme = {}

--- Set colorscheme (idempotent on name and background)
---@param name string The name of the colorscheme to apply
---@param background string|nil Optional background setting ("light" or "dark")
function Theme.set(name, background)
  if not name or name == "" then return end

  local bg = (background == "light" or background == "dark") and background or nil
  if vim.g.colors_name == name and (not bg or vim.o.background == bg) then return end

  if bg then vim.o.background = bg end

  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
end

return Theme
