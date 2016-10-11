local uv = require('luv')
local json = require('json')

local now = uv.now
local unpack = table.unpack
local encode, decode = json.encode, json.decode
local assert, error, ipairs = assert, error, ipairs
local Vector3, SetUnicode = Vector3, SetUnicode

class 'PathServer'

function PathServer:__init()
	self.pool = 0
	self.queue = Deque()
	self.callbacks = {}
end

function PathServer:connect(host, port)

	local udp = uv.new_udp()
	local idle = uv.new_idle()
	local queue = self.queue

	udp:recv_start(function(err, data, sender)
		self.ready = true
		self:handleResponse(data)
	end)

	idle:start(function() -- called every JCMP server tick
		if self.ready and queue:getCount() > 0 then
			local data = queue:popLeft()
			if now() - data.time > 1000 then
				self.callbacks[data.id]({error = 'Request timed out!'})
			else
				data.time = nil
				self.ready = false
				udp:send(encode(data), host, port)
			end
		end
	end)

	self.udp = udp
	self.host = host
	self.port = port
	self.ready = false

	udp:send(encode({method = 'handshake'}), host, port)

end

function PathServer:getPath(start, stop, callback)
	return self:sendRequest('getPath', {
		start = {start.x, start.y, start.z},
		stop = {stop.x, stop.y, stop.z},
	}, callback)
end

function PathServer:sendRequest(method, data, callback)

	local id = self.pool
	self.callbacks[id] = callback
	self.pool = id + 1

	data.id = id
	data.method = method

	if self.ready then
		self.ready = false
		self.udp:send(encode(data), self.host, self.port)
	else
		data.time = now()
		self.queue:pushRight(data)
	end

end

function PathServer:handleResponse(data)

	data = decode(data)

	local id = data.id
	if not id then return end
	data.id = nil

	if data.method == 'getPath' then
		local path = data.path
		if path then
			for i, v in ipairs(path) do
				path[i] = Vector3(unpack(v))
			end
		end
	end
	data.method = nil

	local callback = self.callbacks[id]
	if not callback then return end
	self.callbacks[id] = nil

	callback(data)

end
