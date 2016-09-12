local Graph = require('./classes/Graph')
local config = require('./config')

local graph = Graph()
graph:startServer(config.host, config.port)
