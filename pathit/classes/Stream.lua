local class = require('../class')

local Stream = class('Stream')

function Stream:__init(file)
	self[1] = file
end

function Stream:readByte()
	return self[1]:read(1):byte()
end

function Stream:readShort()
	local a, b = self[1]:read(2):byte(1, 2)
	return a + 0x100 * b
end

function Stream:readInt()
	local a, b, c, d = self[1]:read(4):byte(1, 4)
    return a + 0x100 * b + 0x10000 * c + 0x1000000 * d
end

function Stream:close()
	return self[1]:close()
end

return Stream
