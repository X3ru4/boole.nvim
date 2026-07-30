local M = {}
local MAXIMUN_LOOP = 512
local replace_map = {
	increment = {},
	decrement = {},
}
local v_count = 0

---Generate cycle
---@param cycle string[]
---@param allow_caps boolean|nil
function M.generate(cycle, allow_caps)
	for i, current in ipairs(cycle) do
		local next = cycle[i + 1] or cycle[1]

		replace_map.increment[current] = next
		replace_map.decrement[next] = current

		if allow_caps then
			local capitalized_current = current:gsub('^%l', string.upper)
			local capitalized_next = next:gsub('^%l', string.upper)
			local uppercase_current = current:upper()
			local uppercase_next = next:upper()

			replace_map.increment[capitalized_current] = capitalized_next
			replace_map.decrement[capitalized_next] = capitalized_current
			replace_map.increment[uppercase_next] = uppercase_current
			replace_map.decrement[uppercase_current] = uppercase_next
		end
	end
end

---Generate preset cycles
---@param opts string[]
function M.generate_presets(opts)
	local presets = require('boole.presets')
	for _, name in ipairs(opts) do
		if presets[name] then
			for _, val in ipairs(presets[name]) do
				M.generate(unpack(val))
			end
		end
	end
end

---@param direction 'increment'|'decrement'
function M.active(direction)
	local line = vim.api.nvim_get_current_line()
	local start_pos = vim.api.nvim_win_get_cursor(0)
	local correct_pos

	local function try_match()
		for i = 0, MAXIMUN_LOOP do
			local cword = vim.fn.expand('<cword>')
			v_count = vim.v.count > 0 and vim.v.count or v_count

			-- C-a and C-x already handle numbers, no need to try and
			-- match them to out added values.
			if tonumber(cword) or cword:find('%d') then
				return false
			end

			local current_pos = vim.api.nvim_win_get_cursor(0)
			local ccol = current_pos[2] + 1

			if i == MAXIMUN_LOOP or ccol == #line then
				vim.api.nvim_win_set_cursor(0, start_pos)
				return false
			end

			if start_pos[1] < current_pos[1] then
				vim.api.nvim_win_set_cursor(0, start_pos)
				return false
			end

			local match = direction == 'decrement' and replace_map.decrement[cword] or replace_map.increment[cword]

			if match then
				-- Force the cursor to move to the correct position.
				if cword:sub(1, 1) ~= line:sub(ccol, ccol) then
					correct_pos = line:find(cword, ccol)
					if correct_pos and ccol < correct_pos then
						vim.cmd('normal! w')
						goto continue
					end
				end

				for _ = 1, v_count do
					match = direction == 'decrement' and replace_map.decrement[cword] or replace_map.increment[cword]
					cword = match
				end

				v_count = 0
				vim.cmd('normal! "_ciw' .. match)
				vim.cmd('normal! b')
				return true
			end

			vim.cmd('normal! w')
			::continue::
		end
	end

	-- Fallback to original <C-a> and <C-x> functions for numbers.
	if not try_match() then
		if direction == 'increment' then
			vim.cmd('normal!' .. (v_count > 0 and v_count or '') .. '')
		end
		if direction == 'decrement' then
			vim.cmd('normal!' .. (v_count > 0 and v_count or '') .. '')
		end
		v_count = 0
	end
end

---Setup boole
---@param opts boole.config|nil
function M.setup(opts)
	vim.api.nvim_create_user_command('Boole', function(args)
		M.active(args.args)
	end, {
		nargs = 1,
		complete = function()
			return { 'increment', 'decrement' }
		end,
	})

	if not opts then
		return
	end

	if opts.presets then
		M.generate_presets(opts.presets)
	end

	if opts.allow_caps_additions then
		for _, val in ipairs(opts.allow_caps_additions) do
			M.generate(val, true)
		end
	end

	if opts.additions then
		for _, val in ipairs(opts.additions) do
			M.generate(val)
		end
	end

	opts.mappings = opts.mappings or {}
	vim.keymap.set({ 'n', 'v' }, opts.mappings.increment or '<C-a>', '<Cmd>Boole increment<CR>')
	vim.keymap.set({ 'n', 'v' }, opts.mappings.decrement or '<C-x>', '<Cmd>Boole decrement<CR>')
end

return M
