-- colorshift.lua
-- colorscheme_change.lua
-- lua/config/color-chameleon.lua
-- Automatically switch colorscheme based on current working directory
-- Used for distinguishing between local files and remote/mounted filesystems

local Camouflage = {}

-- Default configuration
local default_config = {
	rules = {
		{ path = "~/mnt/", colorscheme = "oasis-mirage" },
	},
	fallback = nil, -- nil means restore previous colorscheme
}

-- Module state
local config = {}
local state = {
	active_rule = nil,
	prev_colorscheme = nil,
}

--- Resolve path to its real absolute path
---@param p string
---@return string
local function realpath(p)
	if not p or p == "" then
		return p
	end
	-- Expand ~ and environment variables
	p = vim.fn.expand(p)
	-- Resolve symlinks
	return (vim.uv or vim.loop).fs_realpath(p) or p
end

--- Apply a colorscheme safely
---@param name string
local function set_colorscheme(name)
	if not name or name == "" then
		return
	end
	if vim.g.colors_name == name then
		return
	end
	pcall(vim.cmd.colorscheme, name)
end

--- Check if environment variable condition matches
---@param env_conditions table|nil
---@return boolean
local function check_env_condition(env_conditions)
	if not env_conditions then
		return true
	end

	for env_var, expected in pairs(env_conditions) do
		local env_value = vim.env[env_var]

		-- If expected is true, just check if the env var exists (is not nil)
		if expected == true then
			if not env_value then
				return false
			end
		-- If expected is false, check that env var doesn't exist or is empty
		elseif expected == false then
			if env_value and env_value ~= "" then
				return false
			end
		-- Otherwise check for exact value match
		else
			if env_value ~= expected then
				return false
			end
		end
	end

	return true
end

--- Get the effective directory (buffer's directory or global cwd)
---@return string|nil Returns the directory, or nil if the buffer should be ignored
local function get_effective_dir()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Ignore special buffer types (floating windows, help, terminal, etc.)
	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
	if buftype ~= "" then
		-- This is a special buffer (terminal, quickfix, help, etc.), ignore it
		return nil
	end

	-- Try to get the directory of the current buffer
	local bufpath = vim.api.nvim_buf_get_name(bufnr)
	if bufpath and bufpath ~= "" then
		local bufdir = vim.fn.fnamemodify(bufpath, ":h")
		if bufdir and bufdir ~= "" and bufdir ~= "." then
			return realpath(bufdir)
		end
	end

	-- Fallback to global cwd
	return realpath(vim.fn.getcwd())
end

--- Find matching rule for current working directory
---@return table|nil rule The matching rule or nil
local function find_matching_rule()
	local cwd = get_effective_dir()

	for _, rule in ipairs(config.rules) do
		local matches = true

		-- Check path condition (if specified)
		if rule.path then
			local rule_path = realpath(rule.path)
			if not rule_path or cwd:sub(1, #rule_path) ~= rule_path then
				matches = false
			end
		end

		-- Check environment variable conditions (if specified)
		if matches and not check_env_condition(rule.env) then
			matches = false
		end

		-- Check custom condition function (if specified)
		if matches and rule.condition and type(rule.condition) == "function" then
			local success, result = pcall(rule.condition, cwd)
			if not success or not result then
				matches = false
			end
		end

		-- All conditions passed, this rule matches
		if matches then
			return rule
		end
	end

	return nil
end

--- Update colorscheme based on current working directory
local function update_colorscheme()
	local effective_dir = get_effective_dir()

	-- Ignore special buffers (floating windows, terminals, etc.)
	if not effective_dir then
		return
	end

	local matching_rule = find_matching_rule()
	local current = vim.g.colors_name

	-- Entering a special directory
	if matching_rule and not state.active_rule then
		state.prev_colorscheme = current
		state.active_rule = matching_rule
		set_colorscheme(matching_rule.colorscheme)

	-- Switching between different special directories
	elseif matching_rule and state.active_rule and matching_rule ~= state.active_rule then
		state.active_rule = matching_rule
		set_colorscheme(matching_rule.colorscheme)

	-- Leaving special directory
	elseif not matching_rule and state.active_rule then
		local restore_to = config.fallback or state.prev_colorscheme
		state.active_rule = nil
		if restore_to then
			set_colorscheme(restore_to)
		end
		state.prev_colorscheme = nil
	end
end

--- Setup the colorscheme switcher
---@param opts table|nil Configuration options
---   - rules: table[] Array of rule tables. Each rule can have:
---       - path: string (optional) Directory path to match
---       - colorscheme: string The colorscheme to apply
---       - env: table (optional) Environment variable conditions
---       - condition: function (optional) Custom function(cwd) returning boolean
---   - fallback: string|nil Colorscheme to use when leaving special dirs (default: restore previous)
---
--- Examples:
---   Simple single path:
---     require("config.color-chameleon").setup({
---       rules = {{ path = "~/mnt/", colorscheme = "oasis-mirage" }}
---     })
---
---   Multiple paths with different colorschemes:
---     require("config.color-chameleon").setup({
---       rules = {
---         { path = "~/mnt/", colorscheme = "oasis-mirage" },
---         { path = "~/remote/", colorscheme = "tokyonight" },
---       },
---       fallback = "catppuccin",
---     })
---
---   With environment variable and custom conditions:
---     require("config.color-chameleon").setup({
---       rules = {
---         { path = "~/mnt/", colorscheme = "oasis-mirage", env = { SSH_CONNECTION = true } },
---         { path = "~/projects/", colorscheme = "catppuccin", condition = function(cwd) return vim.fn.filereadable(cwd .. "/.remote") == 1 end },
---         { colorscheme = "gruvbox", env = { TMUX = true } }, -- no path, just env check
---       },
---     })
function Camouflage.setup(opts)
	-- Merge with defaults
	config = vim.tbl_deep_extend("force", default_config, opts or {})

	-- Validate configuration
	if not config.rules or #config.rules == 0 then
		vim.notify("color-chameleon: No rules configured", vim.log.levels.WARN)
		return
	end

	-- Setup autocmd for both directory changes and buffer switches
	vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
		callback = update_colorscheme,
		desc = "Update colorscheme when changing to/from special directories",
	})

	-- Check on startup
	update_colorscheme()
end

return Camouflage
