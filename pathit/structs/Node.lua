local format = string.format

local ffi = require('ffi')

local struct = require('../struct')
local config = require('../config')
local Vector3 = require('./Vector3')

local Node = struct('Node', Vector3)
-- inherits the methods, not the cdata structure

ffi.cdef[[
typedef struct {
	int16_t x, y, z;
	uint8_t n;
} Node;
]]

ffi.metatype('Node', Node)

function Node:__tostring()
	return format("Node(%i, %i, %i, %i)", self.x, self.y, self.z, self.n)
end

function Node:getConnectedCost(other)
	local distance = self:euclideanDistance(other)
	return other.y == 200 and 2 * distance or distance
end

Node.getHeuristicCost = Node[config.heuristic]

return Node
