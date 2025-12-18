-- lua/color-chameleon/ui/keymaps.lua
-- Keymap configuration and registration for commands with which-key integration support

local Keymaps = {}

local DEFAULT_PREFIX = "<leader>C"
local DEFAULT_KEYMAPS = {
	enable = "e",
	disable = "d",
	env = "v",
	status = "s",
	debug = "D",
	reload = "r",
}

--- Setup keymaps for ColorChameleon commands
--- @param opts table|nil Configuration options with keymaps and lead_prefix
function Keymaps.setup(opts)
	local user_keymaps = opts and opts.keymaps or {}
	local lead_prefix = opts and opts.lead_prefix or DEFAULT_PREFIX

	-- Merge and apply prefix dynamically
	local keymaps = {}
	for key, suffix in pairs(DEFAULT_KEYMAPS) do
		keymaps[key] = user_keymaps[key] or (lead_prefix .. suffix)
	end

	-- Set prefix
	vim.keymap.set("n", lead_prefix, "<nop>", { desc = "chameleon" })

	-- Assign keymaps - use vim.cmd to call the user commands
	vim.keymap.set("n", keymaps.enable, function()
		vim.cmd("ChameleonEnable")
	end, { desc = "Enable camouflage mode" })

	vim.keymap.set("n", keymaps.disable, function()
		vim.cmd("ChameleonDisable")
	end, { desc = "Disable camouflage mode" })

	vim.keymap.set("n", keymaps.env, function()
		vim.cmd("ChameleonEnv")
	end, { desc = "Show environment variables" })

	vim.keymap.set("n", keymaps.status, function()
		vim.cmd("ChameleonStatus")
	end, { desc = "Show chameleon status" })

	vim.keymap.set("n", keymaps.debug, function()
		vim.cmd("ChameleonDebug")
	end, { desc = "Toggle debug mode" })

	vim.keymap.set("n", keymaps.reload, function()
		vim.cmd("ChameleonReload")
	end, { desc = "Reload configuration" })

	-- Check if which-key is installed before registering the group with an icon
	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.add({
			{ lead_prefix, icon = { icon = "", color = "azure", h1 = "WhichKey" }, group = "chameleon" },
		})
	end
end

return Keymaps
