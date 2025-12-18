-- lua/color-chameleon/lib/buffer.lua
-- Buffer detection and filtering utilities

local Buffer = {}

--- Check if buffer is a real editable file
---@param bufnr number
---@return boolean
local function is_real_file(bufnr)
	local bo = vim.bo[bufnr]
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	-- Skip buffers with empty names. They're either:
	-- UI buffers being set up (netrw, explorers) before properties are set
	-- Or new unsaved buffers (will be evaluated later when actually edited)
	if bufname == "" then
		return false
	end

	-- UI buffers are typically not buflisted (netrw, explorers, etc.)
	if not bo.buflisted then
		return false
	end

	-- UI buffers are often readonly or not modifiable (netrw, help, etc.)
	if bo.readonly and not bo.modifiable then
		return false
	end

	-- Real files have absolute paths
	if not bufname:match("^/") and not bufname:match("^%a:") then
		return false
	end

	return true
end

--- Check if we should skip evaluation for this buffer
---@param rules table[]
---@param bufnr number
---@return boolean, string|nil reason for skipping (if skipped)
function Buffer.should_skip(rules, bufnr)
	local current_buftype = vim.bo[bufnr].buftype

	-- For normal buffers (empty buftype), check if it's a real file
	if current_buftype == "" then
		if not is_real_file(bufnr) then
			return true, "not a real file"
		end
		return false
	end

	-- Buffer MUST be listed (bypasses UI buffers)
	if not vim.bo[bufnr].buflisted then
		return true, string.format("special buffer not listed: %s", current_buftype)
	end

	-- Buffer MUST have a matching rule for this type
	for _, rule in ipairs(rules) do
		if rule.buftype then
			if type(rule.buftype) == "table" then
				for _, bt in ipairs(rule.buftype) do
					if bt == current_buftype then
						return false
					end
				end
			elseif rule.buftype == current_buftype then
				return false
			end
		end
	end

	return true, string.format("no rules for buftype: %s", current_buftype)
end

return Buffer
