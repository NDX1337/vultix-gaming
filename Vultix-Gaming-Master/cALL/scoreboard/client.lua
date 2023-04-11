local screenX,screenY = guiGetScreenSize()
local fps = 0
local isHandled = false

addEvent("Scoreboard:updatePlayers",true)
columns = {}
maxWidth = 0
hovablePlayers = {}
headerPos = false
showingRoom = 1
scrollStart = 0
scrollEnd = 0
biggestColumns = 0
header = {}
local state = false
while ((scrollEnd*20)+20 < screenY) do
	scrollEnd = scrollEnd + 1
end
scrollEnd = scrollEnd - 3
scrollDistance = (scrollEnd - scrollStart) + 5

elements = {}
curColumns = {}
maxElements = 0
scrollElements = 0
while ((maxElements*20)+20 < screenY) do
	maxElements = maxElements + 1
end
alpha = 0
font  	= "default-bold"
bigFont	= "default-bold"
height 	= dxGetFontHeight(1,font)
local rt

function toggle(_,kstate)
	if rt then
		if kstate == "down" then
			state = true
			showRoomSelection = false
			selectedPlayer = false
			checkRenderSize()
			if alpha == 0 and (not isHandled) then
				renderScoreboard()
				addEventHandler("onClientRender",root,drawScoreboard)
				isHandled = true
			end
		else
			state = false
		end
	end
end

function sort(p,h)
	elements = p
	header = h
	setElementData(localPlayer,"fps",fps)
	checkRenderSize()
	if state then
		renderScoreboard()
	end
end

function checkRenderSize()
	local ve = header[showingRoom]
	local size = 0
	for i,v in pairs(ve) do
		if type(v[1]) == "string" and v[1] == "COLUMN" then
			size = v[3]
		end
	end
	if size > 0 then
		if size ~= maxWidth then
			if not rt then
				maxWidth = size
				rt = dxCreateRenderTarget(size,screenY,true)
				outputDebugString("Created scoreboard rendertarget! :: cScoreboard.lua CLIENT")
			else
				maxWidth = size
				destroyElement(rt)
				rt = dxCreateRenderTarget(size,screenY,true)
				outputDebugString("Recreated scoreboard rendertarget! :: cScoreboard.lua CLIENT")
			end
		end
	end
end


function setAFK()
    setElementData(localPlayer,"AFK",1)
end
addEventHandler( "onClientMinimize", root, setAFK)

function delAFK()
    setElementData(localPlayer,"AFK",0)
end
addEventHandler( "onClientRestore", root,delAFK)

function renderScoreboard()
	local v = elements[showingRoom]
	elementCount = #v
	headerPosY = (screenY-((maxElements-scrollElements)*20))/2
	scoreboardPosY = headerPosY+70
	if elementCount < maxElements then
		headerPosY = (screenY-((elementCount)*20)-70)/2
		scoreboardPosY = headerPosY+70
	end
	headerPos = false
	dxSetRenderTarget(rt,true)	
	dxSetBlendMode("modulate_add")
	curColumns = header[showingRoom][3][2]
	local i = 0
	for k=1+scrollStart, scrollEnd do
		if v[k] then
			i = i + 1
			if type(v[k]) ~= "string" then
				if type(v[k][1]) ~= "string" then
					if getElementType(v[k][1]) == "player" then
						dxDrawRectangle(0,scoreboardPosY+((i-1)*20), maxWidth, 20, tocolor(0, 0, 0, 75))
						if (v[k][1] ~= selectedPlayer) then
							for _,c in ipairs(curColumns) do
								if c[2] == "ID" then
									dxSetBlendMode("overwrite")
									dxDrawRectangle(c[3],scoreboardPosY+((i-1)*20), c[4], 20, tocolor(0, 0, 0, 173))
									dxSetBlendMode("modulate_add")
									dxDrawText(tostring(getElementData(v[k][1],"ID")), c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
								elseif c[2] == "name" then
									local pName = getPlayerName(v[k][1])
									while (dxGetTextWidth(pName:gsub("#%x%x%x%x%x%x", ""), 1, font)+32) > c[4] do
										pName = pName:sub(1,(#pName-1))
									end
									local AFK = getElementData(v[k][1], "AFK")
									local highestRole = getElementData(v[k][1], "highestRole")
									local donator = getElementData(v[k][1], "isDonator")
									local paddingForIcons = 0
									if highestRole then
										dxDrawImage(c[3], scoreboardPosY+((i-1)*20)+10-dxGetFontHeight(1, font)/2, dxGetFontHeight(1, font), dxGetFontHeight(1, font), "scoreboard/icons/"..highestRole..".png")
										paddingForIcons = paddingForIcons + dxGetFontHeight(1, font)*1.2
									end
									if donator then
										dxDrawImage(paddingForIcons+c[3], scoreboardPosY+((i-1)*20)+10-dxGetFontHeight(1, font)/2, dxGetFontHeight(1, font), dxGetFontHeight(1, font), "scoreboard/icons/Donator.png")
										paddingForIcons = paddingForIcons + dxGetFontHeight(1, font)*1.1
									end
									if AFK == 1 then
									dxDrawText("#ff0000AFK #ffffff"..pName, paddingForIcons+c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true, false)
									else
									dxDrawText(pName, paddingForIcons+c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true, false)
									end
								elseif c[2]:lower():find("points") or c[2] == "gp" then
									local elem = "Guest"
									if getElementData(v[k][1],c[2]) then
										elem = math.floor(getElementData(v[k][1],c[2]))
									end
									dxDrawText(comma_value(elem) or "Guest", c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, true, false, false, false)
								elseif c[2] == "countryCode" then
									local cc = getElementData(v[k][1],c[2]) or "eu"
									dxDrawImage(c[3]+((c[4]-dxGetTextWidth(cc,1,font))/2)-16, scoreboardPosY+((i-1)*20)+3, 16, 11, ":admin/client/images/flags/"..cc..".png")
									dxDrawText(cc, c[3]+((c[4]-dxGetTextWidth(cc,1,font))/2)+1, scoreboardPosY+((i-1)*20), (c[3]+1)+c[4], scoreboardPosY+((i-1)*21)+15, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, false, false)
								
								elseif c[1]:lower():find("rank") then
									local elem = "Guest"
									if getElementData(v[k][1],c[2]) then
										elem = numberToOrdinal(getElementData(v[k][1],c[2]))
									end
									dxDrawText(elem, c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
								elseif c[2] == "points" then
									local elem = "Guest"
									if getElementData(v[k][1],c[2]) then
										elem = getElementData(v[k][1],c[2])
									end
									dxDrawText(elem, c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
								elseif c[2] == "wr" then
									dxDrawText(math.random(1,100).."%", c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
								elseif c[2] == "ping" then
									dxDrawText(getPlayerPing(v[k][1]), c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
								elseif c[2] == "money" then
									local elem = "Guest"
									if getElementData(v[k][1],c[2]) then
										elem = getElementData(v[k][1],c[2])
									end
									dxDrawText("$"..comma_value(elem), c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, true, false, false, false)
								elseif c[2] == "roomID" then
									local elem = 0
									if getElementData(v[k][1],c[2]) then
										elem = getElementData(v[k][1],c[2])
									end
									dxDrawText(convertRNumber(elem), c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "left", "center", true, true, false, false, false)
								else
									local elem = getElementData(v[k][1],c[2])
									if not elem then
										elem = "N/A"
									end
									local align = "center"
									if (dxGetTextWidth(elem, 1, font)-20) > c[3]+c[4] then
										align = "left"
									end
									dxDrawText(elem, c[3], scoreboardPosY+((i-1)*20), c[3]+c[4], scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, align, "center", true, false, false, false, false)
								end
							end
						else
							extraTabSize = (maxWidth-35) / 5

							dxSetBlendMode("overwrite")
							dxDrawRectangle(0,scoreboardPosY+((i-1)*20), 35, 20, tocolor(0, 0, 0, 173))
							dxSetBlendMode("modulate_add")
							dxDrawText(tostring(getElementData(v[k][1],"ID")), 0, scoreboardPosY+((i-1)*20), 35, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)

							dxDrawText("Copy nickname", 35, scoreboardPosY+((i-1)*20), 35 + extraTabSize, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
							dxDrawText("Ignore", 35 + extraTabSize, scoreboardPosY+((i-1)*20), 35 + extraTabSize*2, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
							dxDrawText("Stats", 35 + extraTabSize*2, scoreboardPosY+((i-1)*20), 35 + extraTabSize*3, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
							dxDrawText("Mute", 35 + extraTabSize*3, scoreboardPosY+((i-1)*20), 35 + extraTabSize*4, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
							dxDrawText("Kick", 35 + extraTabSize*4, scoreboardPosY+((i-1)*20), 35 + extraTabSize*5, scoreboardPosY+((i-1)*20)+20, tocolor(255,255,255,255), 1, font, "center", "center", true, false, false, false, false)
						end
					elseif getElementType(v[k][1]) == "team" then
						dxDrawRectangle(0,scoreboardPosY+((i-1)*20), maxWidth, 20, tocolor(0,0,0, 173))
						local r,g,b = getTeamColor(v[k][1])
						dxDrawText(getTeamName(v[k][1]).." ("..v[k][2]..")",40,scoreboardPosY+((i-1)*20), maxWidth, scoreboardPosY+((i-1)*20)+20, tocolor(r,g,b, 255), 1, font, "left", "center", false, false, false, true, false)
					end
				end
			end
		end												
	end
	
	for i,v in ipairs(header[showingRoom]) do
		if v[1] == "COLUMN" then
			curColumns = v[2]
			dxDrawRectangle(0,headerPosY+50, maxWidth, 20, tocolor(0,0,0, 173))
			for _,c in pairs(v[2]) do
				if c[2] == "name" then
					dxDrawText(c[1],c[3], headerPosY+50, c[3]+c[4], 24, tocolor(255,255,255,255), 1, font, "left", "top", false, false, false, true, false)
				elseif c[2] == "ID" then
					dxDrawText(c[1],c[3], headerPosY+50, c[3]+c[4], 24, tocolor(255,255,255,255), 1, font, "center", "top", false, false, false, true, false)
				else
					dxDrawText(c[1],c[3], headerPosY+50, c[3]+c[4], 24, tocolor(255,255,255,255), 1, font, "center", "top", false, false, false, true, false)
				end
			end
		elseif v[1] == "HEADER" then
			dxDrawRectangle(0,headerPosY ,maxWidth,30,tocolor(0,0,0,191))
			dxDrawImage((5-30)/6,math.floor(headerPosY+((15-55)/6)), 50, 50, "files/logo.png")
			dxDrawLine(0,headerPosY,maxWidth,headerPosY,tocolor(170, 8, 68),2)
			dxDrawText(v[2], 40, headerPosY, maxWidth, headerPosY+30, tocolor(255,255,255,255), 1, bigFont, "left", "center", false, false, false, false, false)
			dxDrawText(v[3], 40, headerPosY, maxWidth-5, headerPosY+30, tocolor(255,255,255,255), 1, bigFont, "right", "center", false, false, false, false, false)
		else
			headerPos = {maxWidth - 20, headerPosY+30+(20-15)/2, 15, 15}
			dxDrawRectangle(0,headerPosY+30, maxWidth, 20, tocolor(0, 0, 0, 173))
			dxDrawText(v[1].." ("..v[2].."/"..v[3]..")",40,headerPosY+30, maxWidth, headerPosY+30+20, tocolor(255, 255, 255, 255), 1, font, "left", "center", false, false, false, true, false)
		end
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function drawScoreboard()
	if state then
		if alpha < 255 then
			alpha = math.clamp(alpha+20, 0, 255)
		end
	else
		if alpha > 0 then
			alpha = math.clamp(alpha-20, 0, 255)
			if (alpha - 20) <= 0 then
				removeEventHandler("onClientRender",root,drawScoreboard)
				isHandled = false
				alpha = 0
			end
		end
	end
	dxDrawImage(math.floor((screenX-maxWidth)/2), 0, maxWidth, screenY, rt, 0, 0, 0, tocolor(255, 255, 255, alpha))
end

function restoreRender()
	if rt then
		renderScoreboard()
	end
end

function scroll(key,state)
	if state then
		if elementCount then
			if elementCount > maxElements then
				if key == "mouse_wheel_up" and state == "down" then
					scrollStart = scrollStart - 1
				elseif key == "mouse_wheel_down" and state == "down" then
					scrollStart = scrollStart + 1
				end
				scrollStart = math.clamp(scrollStart, 0, elementCount - (maxElements-3))
				scrollEnd = scrollStart + maxElements-3
				renderScoreboard()
			end
		end
	end
end

function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

local frames = 0
local startT, curT
addEventHandler("onClientRender", root, function()
	if not startT then startT = getTickCount() end
	frames = frames + 1
	curT = getTickCount()
	if curT - startT >= 1000 then 
		fps = frames
		frames = 0
		startT = nil
	end
end)

addEventHandler("onClientRestore",resourceRoot,restoreRender)
bindKey("tab","both",toggle)
bindKey("mouse_wheel_down","down",scroll)
bindKey("mouse_wheel_up","down",scroll)
addEventHandler("Scoreboard:updatePlayers",resourceRoot,sort)

function math.clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local client = fileExists('client.lua')
if client then
	fileDelete("client.lua")
end
