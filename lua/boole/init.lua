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

local feedkeys = vim.api.nvim_feedkeys
local bang = 'nx'

local function scan_line(start, line)
	for i = 0, MAXIMUN_LOOP do
		local cword = vim.call('expand', '<cword>')
		local crow = vim.api.nvim_win_get_cursor(0)[1]

		if tonumber(cword) or cword:find('%d') then
			return
		end

		if start[1] < crow then
			vim.api.nvim_win_set_cursor(0, start)
			return
		end

		if replace_map.increment[cword] or replace_map.decrement[cword] then
			return cword, line:find(cword, start[2])
		end

		if i == MAXIMUN_LOOP then
			vim.api.nvim_win_set_cursor(0, start)
			return
		end

		feedkeys('w', bang, false)
	end
end

---@param direction 'increment'|'decrement'
function M.active(direction)
	v_count = vim.v.count
	local start_pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local match, correct_pos = scan_line(start_pos, line)

	if match then
		if correct_pos then
			feedkeys('b', bang, false)
			local ccol = vim.api.nvim_win_get_cursor(0)[2] + 1
			if match:sub(1, 1) == line:sub(ccol, ccol) then
				goto continue
			end
			vim.api.nvim_win_set_cursor(0, { start_pos[1], correct_pos })
		end

		::continue::

		for _ = 0, v_count do
			match = direction == 'increment' and replace_map.increment[match] or replace_map.decrement[match]
		end

		feedkeys('"_ciw' .. match, bang, false)
		feedkeys('b', bang, false)
	else
		-- Fallback to original <C-a> and <C-x> functions for numbers.
		if direction == 'increment' then
			feedkeys((v_count > 0 and v_count or '') .. '', bang, false)
		end
		if direction == 'decrement' then
			feedkeys((v_count > 0 and v_count or '') .. '', bang, false)
		end
	end
	v_count = 0
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
	vim.keymap.set('n', opts.mappings.increment or '<C-a>', '<Cmd>Boole increment<CR>')
	vim.keymap.set('n', opts.mappings.decrement or '<C-x>', '<Cmd>Boole decrement<CR>')
end

return M
