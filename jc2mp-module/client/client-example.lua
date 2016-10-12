local path
Network:Subscribe('NewPath', function(args)
	path = args.path
end)

local position, n
Network:Subscribe('NearestNode', function(args)
	position, n = args.position, args.n
end)

Events:Subscribe('KeyUp', function(args)
	if args.key == string.byte('P') then Network:Send('PathRequest') end
end)

local color1 = Color.Magenta
local color2 = Color.Cyan
Events:Subscribe('Render', function()

	if path then
		for i, p1 in ipairs(path) do
			Render:DrawCircle(p1, 0.1, color1)
			local p2 = path[i + 1]
			if p2 then Render:DrawLine(p1, p2, color1) end
		end
	end

	if position then
		Render:DrawCircle(position, 0.2, color2)
		if n then
			local txt = tostring(n)
			local pos = Render:WorldToScreen(position)
			pos.x = pos.x - 0.5 * Render:GetTextWidth(txt)
			Render:DrawText(pos, txt, color2)
		end
	end

end)
