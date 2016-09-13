local path, start, stop
local color = Color.Magenta

Network:Subscribe('NewPath', function(args)
	start = args.start
	stop = args.stop
	path = args.path
end)

Events:Subscribe('KeyUp', function(args)
	if args.key == string.byte('P') then Network:Send('PathRequest') end
end)

Events:Subscribe('Render', function()

	if path then
		for i, p1 in ipairs(path) do
			Render:DrawCircle(p1, 0.1, color)
			local p2 = path[i + 1]
			if p2 then Render:DrawLine(p1, p2, color) end
		end
	end

	if start then Render:DrawCircle(start, 0.2, color) end
	if stop then Render:DrawCircle(stop, 0.2, color) end

end)
