-- init.lua

local ColorChameleon = {}
local Config = require("color-chameleon.config")

--- Setup ColorChameleon with user configuration
--- Note: This only configures ColorChameleon.
--- Examples:
--- TODO: add example
---@param user_config table|nil User configuration
function ColorChameleon.setup(user_config)
	Config.setup(user_config)
end

-- Setup API commands
require("color-chameleon.api").setup(ColorChameleon)

return ColorChameleon
