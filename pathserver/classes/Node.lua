local ffi = require('ffi')
local class = require('../class')
local config = require('../config')
local Vector3 = require('./Vector3')

local format = string.format
local seaLevel = config.seaLevel

local Node = class('Node', Vector3)

ffi.cdef[[
typedef struct {
	int16_t x, y, z;
	uint8_t n;
} Node;
]]

function Node:__tostring()
	return format("Node(%i, %i, %i, %i)", self.x, self.y, self.z, self.n)
end

function Node:getConnectedCost(other)
	local distance = self:euclideanDistance(other)
	return other.y == seaLevel and 2 * distance or distance
end

Node.getHeuristicCost = Node[config.heuristic]

ffi.metatype('Node', Node)
return Node
