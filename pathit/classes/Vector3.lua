local format = string.format
local abs, sqrt, min = math.abs, math.sqrt, math.min

local ffi = require('ffi')

local class = require('../class')
local constants = require('../constants')

local DIAGONAL_DIFF = constants.DIAGONAL_DIFF

local Vector3 = class('Vector3')

ffi.cdef[[
typedef struct {
	float x, y, z;
} Vector3;
]]

function Vector3:__tostring()
	return format("Vector3(%g, %g, %g)", self.x, self.y, self.z)
end

function Vector3:componentDistance(other)
	local dx = abs(other.x - self.x)
	local dy = abs(other.y - self.y)
	local dz = abs(other.z - self.z)
	return dx, dy, dz
end

function Vector3:componentDistance2D(other)
	local dx = abs(other.x - self.x)
	local dz = abs(other.z - self.z)
	return dx, dz
end

function Vector3:manhattanDistance(other)
	local dx, dy, dz = self:componentDistance(other)
	return dx + dy + dz
end

function Vector3:manhattanDistance2D(other)
	local dx, dz = self:componentDistance2D(other)
	return dx + dz
end

function Vector3:diagonalDistance(other)
	local dx, dy, dz = self:componentDistance(other)
	return dx + dy + dz - DIAGONAL_DIFF * min(dx, dy, dz)
end

function Vector3:diagonalDistance2D(other)
	local dx, dz = self:componentDistance(other)
	return dx + dz - DIAGONAL_DIFF * min(dx, dz)
end

function Vector3:euclideanDistanceSquared(other)
	local dx, dy, dz = self:componentDistance(other)
	return dx^2 + dy^2 + dz^2
end

function Vector3:euclideanDistanceSquared2D(other)
	local dx, dy = self:componentDistance2D(other)
	return dx^2 + dz^2
end

function Vector3:euclideanDistance(other)
	return sqrt(self:euclideanDistanceSquared(other))
end

function Vector3:euclideanDistance2D(other)
	return sqrt(self:euclideanDistanceSquared2D(other))
end

ffi.metatype('Vector3', Vector3)
return Vector3
