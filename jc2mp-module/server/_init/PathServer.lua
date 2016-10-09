local uv = require('luv')
local json = require('json')

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
			handle:write(encode(queue:popLeft()))
		end
	end)

	self.loop = loop
	self.handle = handle

end

function PathServer:getPath(start, stop, callback)

	if not self.handle then return error('PathServer not connected') end
	local id = self.pool
	if self.callbacks[id] then return error('Too many path requests') end

	self.queue:pushRight({
		id = id,
		start = {start.x, start.y, start.z},
		stop = {stop.x, stop.y, stop.z},
	})

	self.callbacks[id] = callback
	self.pool = id < 255 and id + 1 or 0

end

function PathServer:processData(data)

	data = decode(data)
	local id = data.id

	if id then
		local path = data.path
		if path then
			for i, v in ipairs(path) do
				path[i] = Vector3(unpack(v))
			end
		end
		self.callbacks[id](data)
		self.callbacks[id] = nil
	end

end

function PathServer:disconnect()

	if not self.handle then return end

	self.handle:shutdown(); self.loop:stop()

	if not self.handle:is_closing() then self.handle:close() end
	if not self.loop:is_closing() then self.loop:close() end

	self.handle, self.loop = nil, nil

	print('PathServer disconnected')

end
