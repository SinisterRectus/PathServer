local Graph = require('./classes/Graph')
local config = require('./config')

local function getMemoryUsage() -- for debugging
	collectgarbage()
	collectgarbage()
	return math.floor(collectgarbage("count"))
end

local graph = Graph()
graph:startServer(config.host, config.port)
