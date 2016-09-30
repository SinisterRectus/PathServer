local enums = require('./enums')
local Heuristic = enums.Heuristic

local config = {
	host = '127.0.0.1', -- localhost
	port = 7780, -- default port 7780
	cellSize = 512, -- power of 2, must match file data
	nodeSize = 4, -- power of 2, must match file data
	seaLevel = 200, -- sea level height
	cellLimit = 1000, -- maximum amount of loaded cells (0.5 to 1.0 MB per cell)
	visitedLimit = 10000, -- maximum amount of nodes to visit while pathing
	heuristic = Heuristic.Diagonal, -- A* pathfinding heuristic
	pathToCells = 'pathserver/cells' -- path to cells goes here
}

return config
