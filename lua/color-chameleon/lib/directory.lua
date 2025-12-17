-- lua/color-chameleon/lib/directory.lua
-- Directory utilities

local Directory = {}

--- Resolve path to its real absolute path
---@param path string
---@return string
function Directory.realpath(path)
	if not path or path == "" then
		return path
	end

	local expanded = vim.fn.expand(path)
	local uv = vim.uv or vim.loop
	return uv.fs_realpath(expanded) or expanded
end

--- Get the effective directory (buffer's directory or global cwd)
---@return string|nil Returns the directory, or nil if the buffer should be ignored
function Directory.get_effective()
	local bufnr = vim.api.nvim_get_current_buf()
	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")

	-- Ignore special buffer types
	if buftype ~= "" then
		return nil
	end

	-- Try to get the directory of the current buffer
	local bufpath = vim.api.nvim_buf_get_name(bufnr)
	if bufpath and bufpath ~= "" then
		local bufdir = vim.fn.fnamemodify(bufpath, ":h")
		if bufdir and bufdir ~= "" and bufdir ~= "." then
			return Directory.realpath(bufdir)
		end
	end

	-- Fallback to global cwd
	return Directory.realpath(vim.fn.getcwd())
end

return Directory
