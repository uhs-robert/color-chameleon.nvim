-- lua/color-chameleon/config.lua

local Config = {}
local deepcopy = vim.deepcopy

-- Default configuration
-- stylua: ignore start
Config.defaults = {
  enabled = false, -- Set to true to enable automatic colorscheme switching
  rules = {
    -- Example rule:
    -- { path = "~/mnt/", colorscheme = "gruvbox" },
    -- { path = "~/work/", colorscheme = "tokyonight", env = { TMUX = true } },
    -- { colorscheme = "catppuccin", env = { SSH_CONNECTION = true } },
  },
  fallback = nil, -- Colorscheme to use when no rules match (nil = restore previous)
  keymaps = true, -- Set to false to disable, or pass a table to customize:
  -- keymaps = {
  --   lead_prefix = "<leader>C",  -- Default prefix (default: "<leader>C")
  --   keymaps = {                 -- Override individual keys
  --     enable = "<leader>Ce",
  --     disable = "<leader>Cd",
  --     env = "<leader>Cv",
  --     status = "<leader>Cs",
  --   },
  -- },
}
-- stylua: ignore end

-- Current active configuration
Config.options = deepcopy(Config.defaults)

--- Deep merge two tables
---@param base table The base table
---@param override table The table to merge on top
---@return table merged The merged result
local function deep_merge(base, override)
	local result = deepcopy(base)

	for k, v in pairs(override) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = deep_merge(result[k], v)
		else
			result[k] = v
		end
	end

	return result
end

--- Setup configuration
---@param user_config table|nil User configuration to merge with defaults
function Config.setup(user_config)
	user_config = user_config or {}
	Config.options = deep_merge(Config.defaults, user_config)
end

--- Enable ColorChameleon
function Config.enable()
	Config.options.enabled = true
	vim.g.color_chameleon_enabled = true
end

--- Disable ColorChameleon
function Config.disable()
	Config.options.enabled = false
	vim.g.color_chameleon_enabled = false
end

--- Get current configuration
---@return table config The current configuration
function Config.get()
	return Config.options
end

return Config
