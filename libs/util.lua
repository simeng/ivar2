-- ivar2 IRC utilities and more
-- vim: set noexpandtab:
local util = {
	json = require'cjson',
	simplehttp = require'simplehttp',
}

local color = function(s, color)
	return string.format("\03%02d%s%s", color, s, util.reset())
end
util.color = color

function util.white(s)
	return color(s, 0)
end
function util.black(s)
	return color(s, 1)
end

function util.blue(s)
	return color(s, 2)
end

function util.green(s)
	return color(s, 3)
end

function util.red(s)
	return color(s, 4)
end

function util.maroon(s)
	return color(s, 5)
end

function util.purple(s)
	return color(s, 6)
end

function util.orange(s)
	return color(s, 7)
end

function util.yellow(s)
	return color(s, 8)
end

function util.lightgreen(s)
	return color(s, 9)
end

function util.teal(s)
	return color(s, 10)
end

function util.cyan(s)
	return color(s, 11)
end

function util.lightblue(s)
	return color(s, 12)
end

function util.fuchsia(s)
	return color(s, 13)
end

function util.gray(s)
	return color(s, 14)
end

function util.lightgray(s)
	return color(s, 15)
end

function util.reset()
	return '\015'
end

function util.bold(s)
	return string.format("\002%s\002", s)
end

function util.underline(s)
	return string.format("\031%s\031", s)
end

function util.italic(s)
	return string.format("\029%s\029", s)
end

function util.reverse(s)
	return string.format("\018%s\018", s)
end

function util.rot13(s)
	local byte_a, byte_A = string.byte('a'), string.byte('A')
	return (string.gsub((s or ''), "[%a]",
	function (char)
		local offset = (char < 'a') and byte_A or byte_a
		local b = string.byte(char) - offset -- 0 to 25
		b = ((b + 13) % 26) + offset -- Rotate
		return string.char(b)
	end
	))
end

function util.urlEncode(str)
	return str:gsub(
		'([^%w ])',
		function (c)
			return string.format ("%%%02X", string.byte(c))
		end
	):gsub(' ', '+')
end

function util.trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function util.split(str, delim)
	if str == "" or str == nil then
		return { }
	end
	str = str .. delim
	local _accum_0 = { }
	local _len_0 = 1
	for m in str:gmatch("(.-)" .. delim) do
		_accum_0[_len_0] = m
		_len_0 = _len_0 + 1
	end
	return _accum_0
end

function util.translateWords(str, callback, fixCase, nickpat)
	-- Usage: etc.translateWords(s ,callback) the callback can return new word, false to skip, or nil to keep the same word.
	assert(str)
	assert(callback, "Callback expected")

	local prev = 1
	local result = ""
	local pat = "()([%w'%-]+)()"
	if nickpat then
		pat = "()([%w_'%-%{%}%[%]`%^]+)()"
	end

	for wpos, w, wposEnd in str:gmatch(pat) do
		local wnew = callback(w)
		if wnew ~= false then
			result = result .. str:sub(prev, wpos - 1)
			if wnew then
				if fixCase then
					if w == w:lower() then
					elseif w == w:upper() then
						wnew = wnew:upper()
					elseif w:sub(1, 1) == w:sub(1, 1):upper() then
						wnew = wnew:sub(1, 1):upper() .. wnew:sub(2)
					end
				end
				result = result .. wnew
			else
				result = result .. w
			end
			if not wnew then
				wnew = w
			end
		end
		prev = wposEnd
	end
	result = result .. str:sub(prev)
	return result
end

function util.nonickalert(nicklist, str)
	-- U+200B, ZERO WIDTH SPACE: "\226\128\139"
	local s = str or ''
	local nl = nicklist -- nicklist
	local zwsp = "\226\128\142" -- LTR

	nl = nl or {}

	local nlkeys = {}
	for nick, t in pairs(nicklist) do
		nlkeys[nick:lower()] = true
	end

	return util.translateWords(s, function(x)
		if nlkeys[x:lower()] then
			return x:sub(1, 1) .. zwsp .. x:sub(2)
		end
	end, nil, true)
end

local utf8 = {
	pattern = "([%z\1-\127\194-\244][\128-\191]*)",
}

-- Return utf8 byte sequences
utf8.chars = function(s)
	return s:gmatch(utf8.pattern)
end

-- Return utf8 string length
utf8.len = function(s)
	-- count the number of non-continuing bytes
	return select(2, s:gsub('[^\128-\193]', ''))
end

utf8.reverse = function(s)
	-- reverse the individual greater-than-single-byte characters
	s = s:gsub(utf8.pattern, function (c) return #c > 1 and c:reverse() end)
	return s:reverse()
end

utf8.replace = function(s, map)
	return s:gsub(utf8.pattern, map)
end

-- Very silly function, but helps for norwegians
utf8.lower = function(s)
	local res, c = string.lower(s):gsub('Æ','æ'):gsub('Ø','ø'):gsub('Å','å')
	return res
end

util.utf8 = utf8

return util
