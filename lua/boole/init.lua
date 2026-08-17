local M = {}
local replace_map = { increment = {}, decrement = {} }
local v_count = 0
local keymode = 'nx'

local feedkeys = vim.api.nvim_feedkeys
local get_current_line = vim.api.nvim_get_current_line
local buf_set_text = vim.api.nvim_buf_set_text
local get_cursor = vim.api.nvim_win_get_cursor
local set_cursor = vim.api.nvim_win_set_cursor
local expand = vim.fn.expand
local getpos = vim.fn.getpos

local MAXIMUN_LOOP = 1024
local KC_CTRL_A = vim.keycode('<C-a>')
local KC_CTRL_X = vim.keycode('<C-x>')
local KC_ESC = vim.keycode('<Esc>')

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
				M.generate(val[1], val[2])
			end
		end
	end
end

local function next_word(direction, word)
	return direction and replace_map.increment[word] or replace_map.decrement[word]
end

local function fallback_default(direction, visual_mode, prgs)
	if visual_mode then
		feedkeys('gv', keymode, false)
	end
	if direction then
		feedkeys((v_count > 1 and v_count or '') .. (prgs and 'g' or '') .. KC_CTRL_A, keymode, false)
	else
		feedkeys((v_count > 1 and v_count or '') .. (prgs and 'g' or '') .. KC_CTRL_X, keymode, false)
	end
end

---Zero-based indexing
local function replace_word(word, ln, startcol, endcol, move)
	buf_set_text(0, ln, startcol, ln, endcol, { word })
	if move then
		set_cursor(0, { ln + 1, startcol })
	end
end

local function scan_line(line, move_back, start_pos, end_col)
	for _ = 1, MAXIMUN_LOOP do
		local cword = expand('<cword>')
		local current_pos = get_cursor(0)

		if tonumber(cword) or cword:find('%d') then
			return
		end

		if current_pos[1] > start_pos[1] or (end_col and current_pos[2] > end_col) then
			if move_back then
				set_cursor(0, start_pos)
			end
			return
		end

		if replace_map.increment[cword] or replace_map.decrement[cword] then
			return cword, line:find(cword, start_pos[2] + 1, true)
		end

		feedkeys('w', keymode, false)
	end
end

local function try_match(direction, start_pos, endcol, fallback, visual_mode, prgs, move)
	if move then
		set_cursor(0, start_pos)
	end

	local line = get_current_line()
	local match_word, start_idx = scan_line(line:sub(1, endcol and endcol + 1), not visual_mode, start_pos, endcol)

	if match_word then
		feedkeys('b', keymode, false)
		local current_col = get_cursor(0)[2] + 1

		if start_idx then
			local first_letter_byte = vim.str_byteindex(match_word, 'utf-32', 1)
			local first_letter = match_word:sub(1, first_letter_byte)
			local current_letter = line:sub(current_col, current_col + first_letter_byte - 1)
			local start_letter = line:sub(start_pos[2] + 1, start_pos[2] + 1)

			if start_letter:find('%w') and start_idx >= current_col and current_letter == first_letter then
				start_idx = current_col
			end
		else
			start_idx = current_col
		end

		local nword
		v_count = v_count < 2 and 1 or v_count
		for _ = 1, v_count do
			nword = next_word(direction, match_word)
		end

		replace_word(nword, start_pos[1] - 1, start_idx - 1, start_idx - 1 + #match_word, not visual_mode)
	elseif fallback then
		fallback_default(direction, visual_mode, prgs)
	end
end

local function active(direction, prgs)
	v_count = vim.v.count
	local mode = vim.api.nvim_get_mode().mode
	local start_pos = get_cursor(0)
	if mode == 'v' or mode == 'V' or mode == '\22' then
		local end_pos = getpos('v')
		feedkeys(KC_ESC, keymode, false)

		-- Normalize position
		end_pos[1], end_pos[2] = end_pos[2], end_pos[3] - 1
		end_pos[3], end_pos[4] = nil, nil

		if start_pos[1] > end_pos[1] then
			start_pos, end_pos = end_pos, start_pos
		end
		if start_pos[1] == end_pos[1] and start_pos[2] > end_pos[2] then
			start_pos[2], end_pos[2] = end_pos[2], start_pos[2]
		end

		if mode == 'V' then
			if start_pos[1] == end_pos[1] then
				try_match(direction, start_pos, nil, true, nil, prgs, nil)
			else
				local line_count = end_pos[1] - start_pos[1]
				if line_count >= MAXIMUN_LOOP then
					vim.notify('Too much lines, maximun is ' .. MAXIMUN_LOOP('lines'), vim.log.levels.WARN)
					v_count = 0
					return
				end

				start_pos[2] = 0
				for _ = 0, line_count do
					try_match(direction, start_pos, nil, nil, true, prgs, true)
					start_pos[1] = start_pos[1] + 1
				end
				fallback_default(direction, true, prgs)
			end
		else
			if start_pos[1] == end_pos[1] then
				try_match(direction, start_pos, end_pos[2], true, nil, prgs, nil)
			else
				local line_count = end_pos[1] - start_pos[1]
				if line_count >= MAXIMUN_LOOP then
					vim.notify('Too much lines, maximun is ' .. MAXIMUN_LOOP('lines'), vim.log.levels.WARN)
					v_count = 0
					return
				end

				for i = 0, line_count do
					if i == 1 and mode ~= '\22' then
						start_pos[2] = 0
					end

					if i == line_count or mode == '\22' then
						try_match(direction, start_pos, end_pos[2], nil, true, prgs, true)
					else
						try_match(direction, start_pos, nil, nil, true, prgs, true)
					end
					start_pos[1] = start_pos[1] + 1
				end
			end
		end
	else
		try_match(direction, start_pos, nil, true, nil, prgs, nil)
	end
	v_count = 0
end

function M.increment(prgs)
	active(true, prgs)
end
function M.decrement(prgs)
	active(false, prgs)
end

---Setup boole
---@param opts boole.config|nil
function M.setup(opts)
	if not opts then
		return
	end

	if opts.use_default_mappings or opts.use_default_mappings == nil then
		local map = vim.keymap.set
		local mode = { 'n', 'x' }

		map(mode, '<C-a>', M.increment)
		map(mode, '<C-x>', M.decrement)

		map(mode, 'g<C-a>', function()
			M.increment(true)
		end)
		map(mode, 'g<C-x>', function()
			M.decrement(true)
		end)
	end

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

	if opts.maximun_loop and opts.maximun_loop > 0 then
		MAXIMUN_LOOP = opts.maximun_loop
	end

	if opts.presets then
		M.generate_presets(opts.presets)
	end
end

return M
