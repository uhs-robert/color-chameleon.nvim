-- lua/color-chameleon/init.lua

local ColorChameleon = {}
local Config = require("color-chameleon.config")

--- Setup ColorChameleon with user configuration
---@param user_config table|nil User configuration
function ColorChameleon.setup(user_config)
	Config.setup(user_config)

	-- Setup autocommands if enabled
	local AutoCommands = require("color-chameleon.lib.auto_commands")
	AutoCommands.setup()
end

-- Setup API commands
require("color-chameleon.api").setup(ColorChameleon)

return ColorChameleon
