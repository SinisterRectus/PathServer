local uv = require('luv')
local json = require('json')

local now = uv.now
local unpack = table.unpack
local assert, error, ipairs = assert, error, ipairs
local Vector3, SetUnicode = Vector3, SetUnicode

local _encode = json.encode
local function encode(tbl)
	SetUnicode(false)
	local str = _encode(tbl)
	SetUnicode(true)
	return str
end

local _decode = json.decode
local function decode(str)
	SetUnicode(false)
	local tbl = _decode(str)
	SetUnicode(true)
	return tbl
end

class 'PathServer'

function PathServer:__init()
	self.pool = 0
	self.queue = Deque()
	self.callbacks = {}
end

function PathServer:connect(host, port)

	local udp = uv.new_udp()
	local idle = uv.new_idle()
	local ready = false
	local queue = self.queue

	udp:recv_start(function(err, data, sender)
		ready = true
		self:processData(data)
	end)

	idle:start(function() -- called every JCMP server tick
		if ready and queue:getCount() > 0 then
			local data = queue:popLeft()
			if now() - data.time > 1000 then
				self.callbacks[data.id]({error = 'Request timed out!'})
			else
				ready = false
				data.time = nil
				udp:send(encode(data), host, port)
			end
		end
	end)

	udp:send(encode({handshake = true}), host, port)

end

function PathServer:getPath(start, stop, callback)

	local id = self.pool

	self.queue:pushRight({
		id = id,
		start = {start.x, start.y, start.z},
		stop = {stop.x, stop.y, stop.z},
		time = now(),
	})

	self.callbacks[id] = callback
	self.pool = id + 1

end

function PathServer:processData(data)

	data = decode(data)

	local id = data.id
	if not id then return end
	data.id = nil

	local callback = self.callbacks[id]
	if not callback then return end
	self.callbacks[id] = nil

	local path = data.path
	if path then
		for i, v in ipairs(path) do
			path[i] = Vector3(unpack(v))
		end
	end

	callback(data)

end
