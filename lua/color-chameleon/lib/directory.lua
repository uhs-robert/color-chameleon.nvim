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
---@return string|nil Returns the directory, or nil if unable to determine
function Directory.get_effective()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Try to get the directory of the current buffer
	local bufpath = vim.api.nvim_buf_get_name(bufnr)
	if bufpath and bufpath ~= "" then
		local bufdir = vim.fn.fnamemodify(bufpath, ":h")
		if bufdir and bufdir ~= "" and bufdir ~= "." then
			local resolved = Directory.realpath(bufdir)
			if resolved then
				return resolved
			end
		end
	end

	-- Fallback to global cwd (works for special buffers like terminal, help, etc.)
	return Directory.realpath(vim.fn.getcwd())
end

return Directory
