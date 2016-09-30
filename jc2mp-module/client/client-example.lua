local path, start, stop
Network:Subscribe('NewPath', function(args)
	start, stop, path = args.start, args.stop, args.path
end)

Events:Subscribe('KeyUp', function(args)
	if args.key == string.byte('P') then Network:Send('PathRequest') end
end)

local color = Color.Magenta
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
