local char = string.char
local floor = math.floor
local Vector3 = require('./classes/Vector3')

local codecs = {}

local function encodeShort(n)
	n = n + 32768
	assert(0 <= n and n <= 65535, 'number out of range')
	return char(floor(n % 256), floor(n / 256 % 256))
end

local function decodeShort(s)
	local a, b = s:byte(1, 2)
	return a + 256 * b - 32768
end

function codecs.encodeVector(v)
	local x = encodeShort(v.x)
	local y = encodeShort(v.y)
	local z = encodeShort(v.z)
	return x .. y .. z
end

function codecs.decodeVector(s)
	local x = decodeShort(s:sub(1, 2))
	local y = decodeShort(s:sub(3, 4))
	local z = decodeShort(s:sub(5, 6))
	return Vector3(x, y, z)
end

return codecs
