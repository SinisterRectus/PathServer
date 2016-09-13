local char = string.char
local floor = math.floor
local insert = table.insert
local assert = assert
local Vector3 = Vector3
local SetUnicode = SetUnicode

local uv = require('luv')

local function encodeNumber(n) -- int16
	n = floor(n + 32768.5) -- offset and round
	assert(0 <= n and n <= 65535, 'number out of range')
	return char(floor(n % 256), floor(n / 256 % 256))
end

local function decodeNumber(s) -- int16
	local a, b = s:byte(1, 2)
	return a + 256 * b - 32768
end

local function encodeVector(v)
	local x = encodeNumber(v.x)
	local y = encodeNumber(v.y)
	local z = encodeNumber(v.z)
	return x .. y .. z
end

local function decodeVector(s)
	local x = decodeNumber(s:sub(1, 2))
	local y = decodeNumber(s:sub(3, 4))
	local z = decodeNumber(s:sub(5, 6))
	return Vector3(x, y, z)
end

class 'PathServer'

function PathServer:__init()
	self.pool = 0
	self.queue = Deque()
	self.callbacks = {}
end

function PathServer:connect(host, port)

	local loop = uv.new_idle()
	local handle = uv.new_tcp()
	local ready = false
	local queue = self.queue

	handle:connect(host, port, function(err)
		assert(not err, err)
		print('PathServer connected')
		handle:read_start(function(err, data)
			if data then
				self:processData(data)
				ready = true
			else
				self:disconnect()
			end
		end)
	end)

	loop:start(function() -- called every JCMP server PreTick
		if ready and queue:getCount() > 0 then
			ready = false
			handle:write(queue:popLeft())
		end
	end)

	self.loop = loop
	self.handle = handle

end

function PathServer:getPath(start, stop, callback)

	if not self.handle then return error('PathServer not connected') end
	if self.callbacks[self.pool] then return error('Too many path requests') end

	local id = char(self.pool) -- might increase to two bytes
	local v1 = encodeVector(start)
	local v2 = encodeVector(stop)

	self.queue:pushRight(id .. v1 .. v2)
	self.callbacks[self.pool] = callback
	self.pool = self.pool < 255 and self.pool + 1 or 0

end

function PathServer:processData(data)

	SetUnicode(false)

	local type = data:sub(1, 1)
	if type == '0' then return end

	local path = nil
	local id = data:sub(2, 2):byte()

	if type == '2' then
		path = {}
		for i = 3, #data, 6 do
			local str = data:sub(i, i + 5)
			insert(path, decodeVector(str))
		end
	end

	SetUnicode(true)

	self.callbacks[id](path)
	self.callbacks[id] = nil

end

function PathServer:disconnect()

	if not self.handle then return end

	self.handle:shutdown(); self.loop:stop()

	if not self.handle:is_closing() then self.handle:close() end
	if not self.loop:is_closing() then self.loop:close() end

	self.handle, self.loop = nil, nil

	print('PathServer disconnected')

end
