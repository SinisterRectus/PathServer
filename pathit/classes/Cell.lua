local time = os.time
local format = string.format
local wrap, yield = coroutine.wrap, coroutine.yield
local floor, random, abs = math.floor, math.random, math.abs

local Node = require('../structs/Node')
local Vector3 = require('../structs/Vector3')

local class = require('../class')
local config = require('../config')
local constants = require('../constants')

local HUGE = math.huge
local MAP_OFFSET = constants.MAP_OFFSET

local Cell = class('Cell')

function Cell:__init(x, y, count)
	self.x = x
	self.y = y
	self.nodes = {}
	self.nodeCount = 0
	self.averageHeight = 0
	self.lastVisited = time()
end

function Cell:__tostring()
	return format("Cell(%i, %i)", self.x, self.y)
end

function Cell:addNode(x, y, z, n)
	local nodes = self.nodes
	local node = Node(x, y, z, n)
	nodes[x] = nodes[x] or {}
	-- if we've already visited this (x, z) position
	if nodes[x][z] then
		-- and there is only one node stored there,
		if type(nodes[x][z]) == 'cdata' then
			-- then expand this table to allow for multiple nodes
			local prior = nodes[x][z]
			-- and store the previous node in the expanded table
			nodes[x][z] = {[prior.y] = prior}
		end
		-- store the new node with the previous node(s)
		nodes[x][z][y] = node
	else
		-- otherwise, store the new node by itself
		nodes[x][z] = node
	end
	local oldCount = self.nodeCount
	local newCount = oldCount + 1
	self.averageHeight = (y + oldCount * self.averageHeight) / newCount
	self.nodeCount = newCount
	return node
end

function Cell:getNode(x, y, z)

	local nodes = self.nodes
	-- look for any nodes at the (x, z) position
	local node2D = nodes[x] and nodes[x][z]
	-- if there are none, then exit early
	if not node2D then return end
	-- if only one node is found, then return it
	if type(node2D) == 'cdata' then return node2D end
	-- if there are multiple nodes, and we have an exact y value,
	-- then return the node corresponding to that y value
	if node2D[y] then return node2D[y] end
	-- otherwise, find and return the best match for the given y value
	-- should be inexpensive, since most 2D positions have few nodes
	local nearestDistance, nearestNode = HUGE
	for other, node in pairs(node2D) do
		local distance = abs(other - y)
		if distance < nearestDistance then
			nearestDistance = distance
			nearestNode = node
		end
	end

	return nearestNode

end

function Cell:getNodes()
	return wrap(function()
		for x, v in pairs(self.nodes) do
			for z, v in pairs(v) do
				-- if there is only one node, return it
				if type(v) == 'cdata' then
					yield(v)
				else
					-- otherwise, return all of the nodes found
					for y, node in pairs(v) do
						yield(node)
					end
				end
			end
		end
	end)
end

function Cell:getRandomNode()
	local n, r = 1, random(self.nodeCount)
	for node in self:getNodes() do
		if n == r then return node end
		n = n + 1
	end
end

function Cell:getCenter() -- approximate vector, not an exact node
	local cellSize = config.cellSize
	local x = self.x * cellSize + 0.5 * cellSize - MAP_OFFSET
	local z = self.y * cellSize + 0.5 * cellSize - MAP_OFFSET
	return Vector3(x, self.averageHeight, z)
end

function Cell:getNearestNode(position)

	local nodeSize = config.nodeSize
	local x = floor(position.x / nodeSize + 0.5) * nodeSize
	local z = floor(position.z / nodeSize + 0.5) * nodeSize

	local nearestNode = self:getNode(x, position.y, z)

	if not nearestNode then
		local nearestDistance = HUGE
		for node in self:getNodes() do
			local distance = position:euclideanDistanceSquared(node)
			if distance < nearestDistance then
				nearestDistance = distance
				nearestNode = node
			end
		end
	end

	-- should only fail if no nodes are loaded
	assert(nearestNode, 'No node discovered')
	return nearestNode

end

return Cell
