local function getPathForPlayer(server, player)

	local start = player:GetPosition()
	local stop = player:GetAimTarget().position

	server:getPath(start, stop, function(args)
		if args.error then
			Chat:Send(player, args.error, Color.Silver)
		else
			Network:Send(player, 'NewPath', {
				start = start, stop = stop, path = args.path,
			})
		end
	end)

end

-- initialize a path server
local pathServer = PathServer()
pathServer:connect('127.0.0.1', 7780)

-- get ready for path requests from clients
Network:Subscribe('PathRequest', function(_, player)
	getPathForPlayer(pathServer, player)
end)

-- adjust the time delay and uncomment the function call to run
local function stressTest()

	local timer = Timer()
	local delay = 500 -- milliseconds

	Events:Subscribe('PostTick', function()
		if timer:GetMilliseconds() < delay then return end
		timer:Restart()
		for player in Server:GetPlayers() do
			local state = player:GetState()
			if state == 4 or state == 5 then
				getPathForPlayer(pathServer, player)
			end
		end
	end)

end
-- stressTest()
