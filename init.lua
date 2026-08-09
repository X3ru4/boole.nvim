local M = {}
local MAXIMUN_LOOP = 1024
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
local get_current_line = vim.api.nvim_get_current_line
local get_mode = vim.api.nvim_get_mode
local buf_set_text = vim.api.nvim_buf_set_text -- zero-based indexing
local get_cursor = vim.api.nvim_win_get_cursor -- (1, 0) indexing
local set_cursor = vim.api.nvim_win_set_cursor -- (1, 0) indexing
local expand = vim.fn.expand
local getpos = vim.fn.getpos -- one-based indexing
local bang = 'nx'

---@param end_col integer zero-based indexing
local function scan_line(line, start, end_col)
	for i = 0, MAXIMUN_LOOP do
		local current_pos = get_cursor(0)
		if start[1] < current_pos[1] or (end_col and end_col < current_pos[2]) then
			set_cursor(0, start)
			return
		end

		local cword = expand('<cword>')

		if tonumber(cword) or cword:find('%d') then
			return
		end

		if replace_map.increment[cword] or replace_map.decrement[cword] then
			return cword, line:find(cword, start[2] + 1, true)
		end

		if i == MAXIMUN_LOOP then
			set_cursor(0, start)
			return
		end

		feedkeys('w', bang, false)
	end
end

local function try_match(direction, startpos, endpos, move)
	if move then
		set_cursor(0, startpos)
	end
	local sta_ln, sta_col = startpos[1], startpos[2]
	local line = get_current_line():sub(1, endpos and endpos[2] + 1)
	local match, match_start = scan_line(line, startpos, endpos and endpos[2])

	if match then
		local col
		-- Skip if only one character
		if vim.str_utfindex(match, 'utf-32') > 1 then
			feedkeys('b', bang, false)
			col = get_cursor(0)[2] + 1
		end

		-- We need to move back to check because `match_start`
		-- might be finding the wrong word.
		if match_start then
			-- Get the first byte of the character.
			local char_byte = vim.str_utf_end(match, 1)
			if
				match:sub(1, 1 + char_byte) == line:sub(col, col + char_byte)
				and not line:sub(sta_col + 1, sta_col + 1):find('%A')
			then
				match_start = col
			end
		else
			match_start = col
		end

		local cword = match

		if v_count < 2 then
			match = direction == 'increment' and replace_map.increment[match] or replace_map.decrement[match]
		else
			for _ = 1, v_count do
				match = direction == 'increment' and replace_map.increment[match] or replace_map.decrement[match]
			end
		end

		buf_set_text(0, sta_ln - 1, match_start - 1, sta_ln - 1, match_start + #cword - 1, { match })
		set_cursor(0, { sta_ln, match_start - 1 })
	else
		-- Fallback to original <C-a> and <C-x> functions for numbers.
		if direction == 'increment' then
			feedkeys((v_count > 0 and v_count or '') .. '', bang, false)
		end
		if direction == 'decrement' then
			feedkeys((v_count > 0 and v_count or '') .. '', bang, false)
		end
	end
end

---@param direction 'increment'|'decrement'
function M.active(direction)
	v_count = vim.v.count
	local startpos = get_cursor(0)
	local mode = get_mode().mode
	if mode == 'v' or mode == 'V' or mode == '\22' then
		local endpos = getpos('v')
		local startln, startcol = startpos[1], startpos[2]
		local endln, endcol = endpos[2], endpos[3] - 1

		-- Normalize the position.
		if startln > endln then
			startln, endln = endln, startln
			startpos[2], endcol = endcol, startcol
		end
		if startln == endln and startcol > endcol then
			startcol, endcol = endcol, startcol
		end
	else
		try_match(direction, startpos)
	end
	v_count = 0
end

---Setup boole
---@param opts boole.config|nil
function M.setup(opts)
	vim.api.nvim_create_user_command('Boole', function(args)
		local start = vim.uv.hrtime()
		M.active(args.args)
		print('' .. (vim.uv.hrtime() - start) / 1000001)
	end, {
		nargs = 1,
		complete = function()
			return { 'increment', 'decrement' }
		end,
	})

	if not opts then
		return
	end

	opts.mappings = opts.mappings or {}
	vim.keymap.set({ 'n', 'x' }, opts.mappings.increment or '<C-a>', '<Cmd>Boole increment<CR>')
	vim.keymap.set({ 'n', 'x' }, opts.mappings.decrement or '<C-x>', '<Cmd>Boole decrement<CR>')

	if opts.additions then
		for _, val in ipairs(opts.additions) do
			M.generate(val)
		end
	end

	if opts.allow_caps_additions then
		for _, val in ipairs(opts.allow_caps_additions) do
			M.generate(val, true)
		end
	end

	if opts.maximun_move and opts.maximun_move > 1 then
		MAXIMUN_LOOP = opts.maximun_move
	end

	if opts.presets then
		M.generate_presets(opts.presets)
	end
end

return M
