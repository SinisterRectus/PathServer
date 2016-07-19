local Graph = require('./classes/Graph')
local Node = require('./structs/Node')
local config = require('./config')
local uv = require('uv')
local ffi = require('ffi')

function table.count(tbl)
	local n = 0
	for k in pairs(tbl) do
		n = n + 1
	end
	return n
end

local function getMemoryUsage()
	collectgarbage()
	collectgarbage()
	return math.floor(collectgarbage("count"))
end

local m = getMemoryUsage()
local t = os.clock()

local n = 10000

local size = config.cellSize / config.nodeSize

local cells = {}
for x = 0, 63 do
	for y = 0, 63 do
		local cell = {}
		cell.nodes = ffi.new(string.format('Node[%i][%i]', size, size))
		table.insert(cells, cell)
	end
end

-- local graph = Graph()
-- graph:loadCell(6, 29)

p(getMemoryUsage() - m, os.clock() - t)
