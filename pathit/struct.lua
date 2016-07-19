local ffi = require('ffi')

local meta = {}

function meta:__call(...)
	return ffi.new(self.__name, ...)
end

function meta:__tostring()
	return 'struct: ' .. self.__name
end

local default = {}

function default:__tostring()
	return 'instance of struct: ' .. self.__name
end

return function(name, base)

	local struct = setmetatable({}, meta)

	for k, v in pairs(default) do
		struct[k] = v
	end

	if base then
		for k, v in pairs(base) do
			struct[k] = v
		end
	end

	struct.__name = name
	struct.__base = base
	struct.__index = struct

	return struct

end
