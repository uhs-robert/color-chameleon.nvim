-- lua/color-chameleon/config.lua

local Config = {}
local deepcopy = vim.deepcopy

-- Default configuration
-- stylua: ignore start
Config.defaults = {
  enabled = true, -- Set to false to disable this plugin
  debug = false, -- Set to true to enable debug logging
  rules = {
    -- Example rule:
    -- { path = "~/mnt/", colorscheme = "gruvbox" },
    -- { path = "~/work/", colorscheme = "tokyonight", env = { TMUX = true } },
    -- { colorscheme = "catppuccin", env = { SSH_CONNECTION = true } },
  },
  default = nil, -- Colorscheme to use when no rules match (nil = restore previous)
  keymaps = true, -- Set to false to disable, or pass a table to customize:
  -- keymaps = {
  --   lead_prefix = "<leader>C",  -- Default prefix (default: "<leader>C")
  --   keymaps = {                 -- Override individual keys
  --     toggle = "<leader>Cc",
  --     env = "<leader>Cv",
  --     status = "<leader>Cs",
  --     debug = "<leader>Cd",
  --     reload = "<leader>Cr",
  --     inspect = "<leader>Ci",
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

	local errors = {}
	local Validate = require("color-chameleon.lib.validate")

	-- Validate default type
	if Config.options.default and type(Config.options.default) ~= "string" then
		table.insert(errors, "Default must be a string or nil")
	end

	-- Validate rules structure
	local rules_valid, rule_errors = Validate.all_rules(Config.options.rules or {})
	if not rules_valid then
		vim.list_extend(errors, rule_errors)
	end

	if #errors > 0 then
		vim.notify(
			"ColorChameleon: Configuration validation failed:\n" .. table.concat(errors, "\n"),
			vim.log.levels.ERROR
		)
	end
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

--- Reload configuration and reapply rules
---@param user_config table|nil Optional new configuration to apply
function Config.reload(user_config)
	-- If new config provided, merge it
	if user_config then
		Config.setup(user_config)
	end

	-- Recreate autocommands if enabled
	if Config.options.enabled then
		local AutoCommands = require("color-chameleon.lib.auto_commands")
		AutoCommands.setup()

		-- Re-scan surroundings
		local Chameleon = require("color-chameleon.chameleon")
		Chameleon.scan_surroundings(Config.options)
	end
end

return Config
