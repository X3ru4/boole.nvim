local M = {}
local replace_map = { increment = {}, decrement = {} }
local match_words = {}
local v_count = 0
local keymode = 'nx'

local feedkeys = vim.api.nvim_feedkeys
local get_current_line = vim.api.nvim_get_current_line
local buf_set_text = vim.api.nvim_buf_set_text
local get_cursor = vim.api.nvim_win_get_cursor
local set_cursor = vim.api.nvim_win_set_cursor
local expand = vim.fn.expand
local getpos = vim.fn.getpos

local MAXIMUM_LOOP = 1024
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
			replace_map.increment[uppercase_current] = uppercase_next
			replace_map.decrement[uppercase_next] = uppercase_current
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
	local pre_col = -1
	for _ = 1, MAXIMUM_LOOP do
		local cword = expand('<cword>')
		local current_pos = get_cursor(0)

		if tonumber(cword) or cword:find('%d') then
			return
		end

		if current_pos[2] == pre_col then
			if move_back then
				set_cursor(0, start_pos)
			end
			return
		end

		if current_pos[1] > start_pos[1] or (end_col and current_pos[2] > end_col) then
			if move_back then
				set_cursor(0, start_pos)
			end
			return
		end

		if replace_map.increment[cword] or replace_map.decrement[cword] then
			return cword, line:find(cword, start_pos[2] + 1, true), current_pos[2]
		end

		pre_col = current_pos[2]
		feedkeys('w', keymode, false)
	end
end

local function try_match(direction, start_pos, endcol, fallback, visual_mode, move, prgs, count, vis_singleline)
	if move then
		set_cursor(0, start_pos)
	end

	local line = get_current_line()
	local word, start_idx, stop_col

	if vis_singleline then
		local selection = line:sub(start_pos[2] + 1, endcol and endcol + 1)
		if replace_map.increment[selection] or replace_map.decrement[selection] then
			word = selection
			start_idx = line:find(selection, start_pos[2] + 1, true)
		end
	else
		word, start_idx, stop_col = scan_line(line:sub(1, endcol and endcol + 1), not visual_mode, start_pos, endcol)
	end

	if word and (vis_singleline and start_idx or true) then
		if not vis_singleline then
			feedkeys('b', keymode, false)
			local current_col = get_cursor(0)[2] + 1

			if start_idx then
				local start_char_byte = vim.str_byteindex(word, 'utf-32', 1)
				local start_char = word:sub(1, start_char_byte)
				local current_char = line:sub(current_col, current_col + start_char_byte - 1)
				local stop_char = line:sub(stop_col + 1, stop_col + 1)
				local origin_char = line:sub(start_pos[2] + 1, start_pos[2] + 1)

				if
					origin_char:find('%w')
					and stop_char:find('%w')
					and start_idx >= current_col
					and current_char == start_char
				then
					start_idx = current_col
				end
			else
				start_idx = current_col
			end
		end

		local nword
		if prgs and visual_mode then
			nword = match_words[(count or 1) - 1] or nword
		end

		v_count = v_count < 2 and 1 or v_count
		for _ = 1, v_count do
			nword = next_word(direction, nword or word)
		end

		replace_word(nword, start_pos[1] - 1, start_idx - 1, start_idx - 1 + #word, not visual_mode)

		if prgs and visual_mode then
			match_words[#match_words + 1] = prgs and nword
		end
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
				try_match(direction, start_pos, nil, true, nil, nil, prgs)
			else
				match_words = {}
				local line_count = end_pos[1] - start_pos[1]
				if line_count >= MAXIMUM_LOOP then
					vim.notify('Too many lines, maximum is ' .. MAXIMUM_LOOP .. ' lines.', vim.log.levels.WARN)
					return
				end

				start_pos[2] = 0
				for i = 0, line_count do
					try_match(direction, start_pos, nil, nil, true, true, prgs, i + 1)
					start_pos[1] = start_pos[1] + 1
				end
				fallback_default(direction, true, prgs)
			end
		else
			if start_pos[1] == end_pos[1] then
				try_match(direction, start_pos, end_pos[2], true, nil, nil, prgs, nil, true)
			else
				match_words = {}
				local line_count = end_pos[1] - start_pos[1]
				if line_count >= MAXIMUM_LOOP then
					vim.notify('Too many lines, maximum is ' .. MAXIMUM_LOOP .. ' lines.', vim.log.levels.WARN)
					return
				end

				for i = 0, line_count do
					if i == 1 and mode ~= '\22' then
						start_pos[2] = 0
					end

					if i == line_count or mode == '\22' then
						try_match(direction, start_pos, end_pos[2], nil, true, true, prgs, i + 1)
					else
						try_match(direction, start_pos, nil, nil, true, true, prgs, i + 1)
					end
					start_pos[1] = start_pos[1] + 1
				end
				fallback_default(direction, true, prgs)
			end
		end
	else
		try_match(direction, start_pos, nil, true, nil, prgs, nil)
	end
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

	if opts.maximum_loop and opts.maximum_loop > 0 then
		MAXIMUM_LOOP = opts.maximum_loop
	end

	if opts.presets then
		M.generate_presets(opts.presets)
	end
end

return M
