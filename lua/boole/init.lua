local M = {}

local MAXIMUN_LOOP = 1024
local KEYCODE_ESC = vim.keycode('<Esc>')
local KEYCODE_CTRL_A = vim.keycode('<C-a>')
local KEYCODE_CTRL_X = vim.keycode('<C-x>')

local replace_map = { increment = {}, decrement = {} }
local v_count = 0
local bang = 'nx'

local feedkeys = vim.api.nvim_feedkeys
local get_current_line = vim.api.nvim_get_current_line
local get_mode = vim.api.nvim_get_mode
local buf_set_text = vim.api.nvim_buf_set_text -- zero-based indexing
local get_cursor = vim.api.nvim_win_get_cursor -- (1, 0) indexing
local set_cursor = vim.api.nvim_win_set_cursor -- (1, 0) indexing
local expand = vim.fn.expand
local getpos = vim.fn.getpos -- one-based indexing
local getregion = vim.fn.getregion

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

---@param end_col integer zero-based indexing
local function scan_line(line, start, end_col)
	for i = 0, MAXIMUN_LOOP do
		local current_pos = get_cursor(0)
		if start[1] < current_pos[1] or (end_col and end_col <= current_pos[2]) then
			set_cursor(0, start)
			return
		end

		local cword = expand('<cword>')

		if tonumber(cword) or cword:find('%d') then
			return
		end

		if replace_map.increment[cword] or replace_map.decrement[cword] then
			print(line:find(cword, start[2] + 1, true))
			return cword, line:find(cword, start[2] + 1, true)
		end

		if i == MAXIMUN_LOOP then
			set_cursor(0, start)
			return
		end

		feedkeys('w', bang, false)
	end
end

local function try_match(direction, startpos, endcol, move, str)
	if move then
		set_cursor(0, startpos)
	end

	local startln, startcol = startpos[1], startpos[2]
	local line = get_current_line():sub(1, endcol and endcol + 1)
	local match, match_start
	if str and replace_map.increment[str] or replace_map.decrement[str] then
		match_start = line:find(str, startpos[2] + 1)
		match = match_start and str or nil
		goto skip_scan
	end
	match, match_start = scan_line(line, startpos, endcol)

	::skip_scan::
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
			col = col and col or match_start
			if
				match:sub(1, 1 + char_byte) == line:sub(col, col + char_byte)
				and not line:sub(startcol + 1, startcol + 1):find('%A')
			then
				match_start = col
			end
		else
			match_start = col
		end

		local cword = match

		if v_count < 2 then
			match = direction and replace_map.increment[match] or replace_map.decrement[match]
		else
			for _ = 1, v_count do
				match = direction and replace_map.increment[match] or replace_map.decrement[match]
			end
		end

		buf_set_text(0, startln - 1, match_start - 1, startln - 1, match_start + #cword - 1, { match })
		set_cursor(0, { startln, match_start - 1 })
	else
		-- Fallback to original <C-a> and <C-x> functions for numbers.
		if direction then
			feedkeys((v_count > 0 and v_count or '') .. KEYCODE_CTRL_A, bang, false)
		end
		if not direction then
			feedkeys((v_count > 0 and v_count or '') .. KEYCODE_CTRL_X, bang, false)
		end
	end
end

---@param direction boolean
local function start_adjust(direction)
	v_count = vim.v.count
	local startpos = get_cursor(0)
	local mode = get_mode().mode
	if mode == 'v' or mode == 'V' or mode == '\22' then
		local endpos = getpos('v')
		local endln, endcol = endpos[2], endpos[3] - 1

		feedkeys(KEYCODE_ESC, bang, false)

		-- Normalize the position.
		if startpos[1] > endln then
			startpos[1], endln = endln, startpos[1]
			startpos[2], endcol = endcol, startpos[2]
		end

		if mode ~= 'V' then
			if startpos[1] == endln then
				if startpos[2] > endcol then
					startpos[2], endcol = endcol, startpos[2]
				end
				local selection = getregion(endpos, getpos('.'), { type = mode })[1]
				try_match(direction, startpos, endcol + #selection, false, selection)
			elseif endln > startpos[1] then
				local line_count = endln - startpos[1]
				for i = 0, line_count do
					startpos[2] = (i > 0 and mode ~= '\22') and 0 or startpos[2]
					if i < line_count and mode ~= '\22' then
						try_match(direction, startpos, nil, true)
					else
						try_match(direction, startpos, endcol, true)
						print(startpos[1], startpos[2], endcol)
					end
					startpos[1] = startpos[1] + 1
				end
			end
		else
			for _ = 0, endln - startpos[1] do
				try_match(direction, startpos, nil, true)
				startpos[1] = startpos[1] + 1
			end
		end
	else
		try_match(direction, startpos)
	end
	v_count = 0
end

function M.increment()
	start_adjust(true)
end
function M.decrement()
	start_adjust(false)
end

---Setup boole
---@param opts boole.config|nil
function M.setup(opts)
	vim.api.nvim_create_user_command('Boole', function(args)
		local direct = M[args.args]
		if type(direct) == 'function' then
			direct()
		end
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
	vim.keymap.set({ 'n', 'x' }, opts.mappings.increment or '<C-a>', M.increment)
	vim.keymap.set({ 'n', 'x' }, opts.mappings.decrement or '<C-x>', M.decrement)

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
