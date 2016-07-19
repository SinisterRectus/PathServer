local Graph = require('./classes/Graph')
local config = require('./config')

local function getMemoryUsage()
	collectgarbage()
	collectgarbage()
	return math.floor(collectgarbage("count"))
end

local m = getMemoryUsage()
local t = os.clock()

local graph = Graph()
graph:loadCell(6, 29)
graph:startServer(config.host, config.port)

p(getMemoryUsage() - m, os.clock() - t)
