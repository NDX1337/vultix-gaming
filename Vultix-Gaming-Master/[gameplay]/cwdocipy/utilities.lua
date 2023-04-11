function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and(alpha < 0 or alpha >255))) then
		return nil
	end
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function removeHex(text, digits)
    assert(type(text) == "string", "Bad argument 1 @ removeHex [String expected, got " .. tostring(text) .. "]")
    assert(digits == nil or (type(digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got " .. tostring(digits) .. "]")
    return string.gsub(text, "#" .. (digits and string.rep("%x", digits) or "%x+"), "")
end

function newNick(name)
	local nick = removeHex(name, 6)
	if nick ~= name and #nick ~= 0 then
		name = nick
	end
	if #nick == 0 then
		name = name:gsub("#", "")
	end
	return name
end

function toboolean(message)
	if message:lower() == "true" then
		return true
	elseif message:lower() == "false" then		
		return false
	end
	return true
end

function getAlivePlayersInTeamCount(theTeam)
	local count = 0
	if isElement(theTeam) then
		local players = theTeam:getPlayers()
		for _,v in pairs(players) do
			if v:getData("state") == "alive" then
				count = count + 1
			end
		end		
	end
	return count
end

function getAlivePlayersInTeam(theTeam)
    local theTable = {}
    local players = theTeam:getPlayers()

    for i,v in pairs(players) do
		if v:getData("state") == "alive" then
            theTable[#theTable+1] = v
        end
    end

    return theTable
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = (player:getName()):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function dxDrawBorderedRectangle(x, y, width, height, color1, color2, _width, postGUI)
    local _width = _width or 1
    dxDrawRectangle(x+1, y+1, width-1, 20-1, tocolor(65, 65, 65, 200), postGUI)
    dxDrawRectangle(x+1, y+20, width-1, height-21, color1, postGUI)
    dxDrawLine(x, y, x+width, y, color2, _width, postGUI) -- Top
    dxDrawLine(x, y, x, y+height, color2, _width, postGUI) -- Left
    dxDrawLine(x, y+height, x+width, y+height, color2, _width, postGUI) -- Bottom
    dxDrawLine(x+width, y, x+width, y+height, color2, _width, postGUI) -- Right
end

local anims, builtins = {}, {"Linear", "InQuad", "OutQuad", "InOutQuad", "OutInQuad", "InElastic", "OutElastic", "InOutElastic", "OutInElastic", "InBack", "OutBack", "InOutBack", "OutInBack", "InBounce", "OutBounce", "InOutBounce", "OutInBounce", "SineCurve", "CosineCurve"}

function table.find(t, v)
	for k, a in ipairs(t) do
		if a == v then
			return k
		end
	end
	return false
end

function table.compare(t1,t2,ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end

	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end

	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not table.compare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not table.compare(v1,v2) then return false end
	end
	return true
end

function animate(f, t, easing, duration, onChange, onEnd)
	assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
	assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
	assert(type(easing) == "string" or (type(easing) == "number" and (easing >= 1 or easing <= #builtins)), "Bad argument @ 'animate' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'animate' [expected function at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
	table.insert(anims, {from = f, to = t, easing = table.find(builtins, easing) and easing or builtins[easing], duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})
	return #anims
end

function destroyAnimation(a)
	if anims[a] then
		table.remove(anims, a)
	end
end

addEventHandler("onClientRender", root, function( )
	local now = getTickCount( )
	for k,v in ipairs(anims) do
		v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
		if now >= v.start+v.duration then
			if type(v.onEnd) == "function" then
				v.onEnd( )
			end
			table.remove(anims, k)
		end
	end
end)