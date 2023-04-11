setCameraClip(false, false)

local sw, sh = guiGetScreenSize()
guiSetInputMode("no_binds_when_editing")

local team1, team2, team3
local tn1, tn2, tn3 = "", "", ""
local tp1, tp2, tp3 = 0, 0, 0
local tc1, tc2, tc3 = "", "", ""
local isSomeoneWon

local clanWarState = "Free"

local firstSend = true
local showHud = true
local isTeam3 = false
local roundsLeft = 0

local mapsTable = {}
local choosenMapsTable = {}

local redoAnimate, isRedoPoll, redoTeam, redoNick = false, false
local redoX, redoA, redoB = sw + sw * 0.5, 0, 0
local isWindow = false
local isShowStop, stopMessage = false, ""

local cst, csw = false, false

local csw_def_id = 0
local cst_def_h, cst_def_m = 12, 0

local csw_id = 0
local cst_h, cst_m = 12, 0

addEvent("receiveMaps", true)
addEventHandler("receiveMaps", root,
function(maps, choosen)
	if maps then
		mapsTable = maps
	end
	if choosen then
		choosenMapsTable = choosen
	end
end)

addEvent("receivePoll", true)
addEventHandler("receivePoll", root,
function(value, nick, team)
	isRedoPoll = value
	if value == false then
		redoX = sw
	else
		if nick then
			redoNick = nick
		else
			redoNick = ""
		end
		if team then
			redoTeam = team
		end
		local text = "Vote by: "..redoNick
		local text1 = "\"go\" for confirm  \"no\" for deny"
		local len = dxGetTextWidth(text, 1, "default-bold")
		local len1 = dxGetTextWidth(text1, 1, "default-bold")
		if team == team1 then
			if localPlayer:getTeam() ~= team2 then
				text = "Vote by: "..redoNick
				text1 = "Waiting for reply"
				len = dxGetTextWidth(text, 1, "default-bold")
				len1 = dxGetTextWidth(text1, 1, "default-bold")
			end
		elseif team == team2 then
			if localPlayer:getTeam() ~= team1 then
				text = "Vote by: "..redoNick
				text1 = "Waiting for reply"
				len = dxGetTextWidth(text, 1, "default-bold")
				len1 = dxGetTextWidth(text1, 1, "default-bold")
			end
		end
		if len1 >= len then
			animate(0, 255, 1, 2000, function(value) redoA = value end)
			animate(0, 220, 1, 2000, function(value) redoB = value end)
			animate(sw + sw * 0.5, sw - len1 - 10, 11, 1000, function(value) redoAnimate = true redoX = value end,
			function() redoAnimate = false end)
		else
			animate(0, 255, 1, 2000, function(value) redoA = value end)
			animate(0, 220, 1, 2000, function(value) redoB = value end)
			animate(sw + sw * 0.5, sw - len - 10, 11, 1000, function(value) redoAnimate = true redoX = value end,
			function() redoAnimate = false end)
		end
	end
end)

function receiveClanWarSettings(value, settings)
	isTeam3 = value

	tn1 = settings.tn1 or ""
	tc1 = settings.tc1 or ""
	tp1 = settings.tp1 or 0
	team1 = settings.team1

	tn2 = settings.tn2 or ""
	tc2 = settings.tc2 or ""
	tp2 = settings.tp2 or 0
	team2 = settings.team2

	rounds = settings.rounds
	roundsLeft = settings.roundsLeft
	clanWarState = settings.clanWarState

	isSomeoneWon = settings.isSomeoneWon or false


	if isTeam3 then
		tn3 = settings.tn3 or ""
		tc3 = settings.tc3 or ""
		tp3 = settings.tp3 or 0
		team3 = settings.team3
		if isWindow then
			if team3Name:getText() ~= tn3 then
				team3Name:setText(tn1)
			end
			if team3Color:getText() ~= tc3 then
				team3Color:setText(tc3)
			end
			if team3Points:getText() ~= tp3 then
				team3Points:setText(tp3)
			end
		end
		if isSomeoneWon then
			if settings.winnerTeam == 1 then
				createTrayNotification(tn1.." won this round "..tn1..":"..tp1.." || "..tn2..":"..tp2.." ||"
																						..tn3..":"..tp3, "default", true)
			elseif settings.winnerTeam == 2 then
				createTrayNotification(tn2.." won this round "..tn1..":"..tp1.." || "..tn2..":"..tp2.." ||"
																						..tn3..":"..tp3, "default", true)
			elseif settings.winnerTeam == 3 then
				createTrayNotification(tn3.." won this round "..tn1..":"..tp1.." || "..tn2..":"..tp2.." ||"
																						..tn3..":"..tp3, "default", true)
			end
		end
	else
		if isSomeoneWon then
			if settings.winnerTeam == 1 then
				createTrayNotification(tn1.." won this round "..tn1..":"..tp1.." || "..tn2..":"..tp2, "default", true)
			elseif settings.winnerTeam == 2 then
				createTrayNotification(tn2.." won this round "..tn1..":"..tp1.." || "..tn2..":"..tp2, "default", true)
			end
		end
	end

	if firstSend then
		bindKey(settings.hudKey, "down", function() showHud = not showHud end)
		firstSend = false
	end

	if isWindow then
		if team1Name:getText() ~= tn1 then
			team1Name:setText(tn1)
		end
		if team1Color:getText() ~= tc1 then
			team1Color:setText(tc1)
		end
		if team1Points:getText() ~= tp1 then
			team1Points:setText(tp1)
		end
		
		if team2Name:getText() ~= tn2 then
			team2Name:setText(tn2)
		end
		if team2Color:getText() ~= tc2 then
			team2Color:setText(tc2)
		end
		if team2Points:getText() ~= tp2 then
			team2Points:setText(tp2)
		end
	end

end
addEvent("receiveClanWarSettings", true)
addEventHandler("receiveClanWarSettings", root, receiveClanWarSettings)

addEvent("showStopTimer", true)
addEventHandler("showStopTimer", root,
function(show, value, remain)
	isShowStop = show
	if value then
		if remain then
			stopMessage = "#FF0000"..remain
			if remain == 0 then
				stopMessage = "#FF0000STOP"
			end
		end
	else
		if remain then
			stopMessage = "#00FF00"..5-remain
			if remain > 1 then
				playSoundFrontEnd(44)
			elseif remain == 1 then
				playSoundFrontEnd(45)
			end
			if remain <= 1 then
				stopMessage = "#00FF00GO"
			end
		end
	end
end)


addEventHandler("onClientRender", root,
function()
	if showHud then
		if isShowStop then
			dxDrawRectangle(0, 0, sw, sh, tocolor(0, 0, 0, 120))
			dxDrawText(stopMessage, 0, 0, sw, sh, _, 8, "pricedown", "center", "center", false, false, false, true)
		end
		if isRedoPoll and not isTeam3 then
			local color = tocolor(redoTeam:getColor()) or tocolor(255, 0, 0)
			local text = "Vote by: "..redoNick
			local text1 = "\"go\" for confirm  \"no\" for deny"
			if redoTeam == team1 then
				if localPlayer:getTeam() ~= team2 then
					text = "Vote by: "..redoNick
					text1 = "Waiting for reply"
				end
			elseif redoTeam == team2 then
				if localPlayer:getTeam() ~= team1 then
					text = "Vote by: "..redoNick
					text1 = "Waiting for reply"
				end
			end
			local len = dxGetTextWidth(text, 1, "default-bold")
			local len1 = dxGetTextWidth(text1, 1, "default-bold")
			text1 = text1:gsub("go", "#00FF00go#FFFFFF")
			text1 = text1:gsub("no", "#FF0000no#FFFFFF")
			if len1 >= len then
				if not redoAnimate and redoX ~= sw + sw * 0.5 then
					local summ = 10 + len1 + redoX
					if summ ~= sw then
						redoX = sw - len1 - 10
					end
				end
				dxDrawBorderedRectangle(redoX-5, sh/1.75, len1+10, 45, tocolor(0, 0, 0, redoB), color, 0.5, false)
				dxDrawText(text, redoX, (sh/1.75)+4, redoX+len1, 20, tocolor(255, 255, 255, redoA), 1, "default-bold", "left")
				dxDrawText(text1, redoX, (sh/1.75)+4+22, redoX+len1, 20, tocolor(255, 255, 255, redoA), 1, "default-bold", "center", "top", false, false, false, true)
			else
				if not redoAnimate and redoX ~= sw + sw * 0.5 then
					local summ = 10 + len + redoX
					if summ ~= sw then
						redoX = sw - len - 10
					end
				end
				dxDrawBorderedRectangle(redoX-5, sh/1.75, len+10, 45, tocolor(0, 0, 0, redoB), color, 0.5, false)
				dxDrawText(text, redoX, (sh/1.75)+4, redoX+len, 20, tocolor(255, 255, 255, redoA), 1, "default-bold", "left")
				dxDrawText(text1, redoX, (sh/1.75)+4+22, redoX+len, 20, tocolor(255, 255, 255, redoA), 1, "default-bold", "center", "top", false, false, false, true)
			end
		end
		local count1, count2, count3 = 0, 0, 0
		local len1, len2, len3 = 0, 0, 0
		local sr, sg = 255, 255
		if clanWarState == "Free" then
			sr, sg = 255, 0
		elseif clanWarState == "Live" then
			sr, sg = 0, 255
		else
			sr, sg = 255, 165
		end
		if isTeam3 then
			if isElement(team1) then count1 = getAlivePlayersInTeamCount(team1) end
			if isElement(team2) then count2 = getAlivePlayersInTeamCount(team2) end
			if isElement(team3) then count3 = getAlivePlayersInTeamCount(team3) end

			len1 = dxGetTextWidth("("..count1..") "..tn1..": "..tp1, 1, "default-bold")
			len2 = dxGetTextWidth("("..count2..") "..tn2..": "..tp2, 1, "default-bold")
			len3 = dxGetTextWidth("("..count3..") "..tn3..": "..tp3, 1, "default-bold")
			if len1 >= len2 and len1 >= len3 then
				dxDrawRectangle(sw-40-len1, (sh/2.1)-6, len1+25, 55, tocolor(0, 0, 0, 120))
				dxDrawText(clanWarState, sw-15, (sh/2.2)-3, sw-40-len1, 20, tocolor(sr, sg, 0), 1, "default-bold", "center")
				dxDrawText("("..count1..") "..tc1..tn1.."#FFFFFF: "..tp1.."\n"
						 .."("..count2..") "..tc2..tn2.."#FFFFFF: "..tp2.."\n"					 
						 .."("..count3..") "..tc3..tn3.."#FFFFFF: "..tp3.."\n"					 
						, sw-40-len1+5, sh/2.1, sw-25, sh,_, 1, "default-bold", "right", "top", false, false, false, true)
			elseif len2 >= len1 and len2 >= len3 then
				dxDrawRectangle(sw-40-len2, (sh/2.1)-6, len2+25, 55, tocolor(0, 0, 0, 120))
				dxDrawText(clanWarState, sw-15, (sh/2.2)-3, sw-40-len2, 20, tocolor(sr, sg, 0), 1, "default-bold", "center")
				dxDrawText("("..count1..") "..tc1..tn1.."#FFFFFF: "..tp1.."\n"
						 .."("..count2..") "..tc2..tn2.."#FFFFFF: "..tp2.."\n"					 
						 .."("..count3..") "..tc3..tn3.."#FFFFFF: "..tp3.."\n"					 
						, sw-40-len2+5, sh/2.1, sw-25, sh,_, 1, "default-bold", "right", "top", false, false, false, true)
			elseif len3 >= len1 and len3 >= len2 then
				dxDrawRectangle(sw-40-len3, (sh/2.1)-6, len3+25, 55, tocolor(0, 0, 0, 120))
				dxDrawText(clanWarState, sw-15, (sh/2.2)-3, sw-40-len3, 20, tocolor(sr, sg, 0), 1, "default-bold", "center")
				dxDrawText("("..count1..") "..tc1..tn1.."#FFFFFF: "..tp1.."\n"
						 .."("..count2..") "..tc2..tn2.."#FFFFFF: "..tp2.."\n"					 
						 .."("..count3..") "..tc3..tn3.."#FFFFFF: "..tp3.."\n"					 
						, sw-40-len3+5, sh/2.1, sw-25, sh,_, 1, "default-bold", "right", "top", false, false, false, true)
			end
		else
			if isElement(team1) then count1 = getAlivePlayersInTeamCount(team1) end
			if isElement(team2) then count2 = getAlivePlayersInTeamCount(team2) end

			local r, g, b = 255, 0, 0

			if localPlayer:getTeam() == team1 then
				if count1 >= count2 then
					r, g, b = 0, 255, 0
				else
					r, g, b = 255, 0, 0
				end
			elseif localPlayer:getTeam() == team2 then
				if count2 >= count1 then
					r, g, b = 0, 255, 0
				else
					r, g, b = 255, 0, 0
				end
			end

			len1 = dxGetTextWidth(tn1..": "..tp1, 1, "default-bold")
			len2 = dxGetTextWidth(tn2..": "..tp2, 1, "default-bold")
			if len1 >= len2 then
				dxDrawRectangle(sw-40-len1, (sh/2.1)-6, len1+25, 20, tocolor(r, g, b, 80))
				dxDrawRectangle(sw-40-len1, (sh/2)-6, len1+25, 40, tocolor(0, 0, 0, 120))
				dxDrawText(clanWarState, sw-15, (sh/2.2)-3, sw-40-len1, 20, tocolor(sr, sg, 0), 1, "default-bold", "center")
				dxDrawText(count1.." #FFFFFFvs "..count2, sw-15, (sh/2.1)-3, sw-40-len1, 20, _, 1, "default-bold", "center"
																						 , "top", false, false, false, true)
			else
				dxDrawRectangle(sw-40-len2, (sh/2.1)-6, len2+25, 20, tocolor(r, g, b, 80))
				dxDrawRectangle(sw-40-len2, (sh/2)-6, len2+25, 40, tocolor(0, 0, 0, 120))
				dxDrawText(clanWarState, sw-15, (sh/2.2)-3, sw-40-len2, 20, tocolor(sr, sg, 0), 1, "default-bold", "center")
				dxDrawText(count1.." #FFFFFFvs "..count2, sw-15, (sh/2.1)-3, sw-40-len2, 20, _, 1, "default-bold", "center"
																						 , "top", false, false, false, true)
			end
			dxDrawText(tc1..tn1.."#FFFFFF: "..tp1.."\n"
					 ..tc2..tn2.."#FFFFFF: "..tp2
					, 0, sh/2, sw-25, sh,_, 1, "default-bold", "right", "top", false, false, false, true)
		end
	end
end)


function window()
	local w, h = 600, 320
	if isWindow then
		if isElement(window) then window:destroy() end
		isWindow = false
		showCursor(false)
		guiSetInputEnabled(false)
		for k in pairs(pickerTable) do
			closePicker(k)
		end
	else
		window = GuiWindow.create(sw/2-w/2, sh/2-h/2, w, h, "Settings", false)
		tabPanel = GuiTabPanel.create(0, 20, w, h, false, window)

		mainTab = GuiTab.create("Main", tabPanel)
		mapsTab = GuiTab.create("Maps", tabPanel)
		-- settingsTab = GuiTab.create("Settings", tabPanel)

		-- #MAIN TAB
		if not isTeam3 then
			local startX = 50
			team1Label = GuiLabel.create(startX, 5, 45, 20, "Team 1:", false, mainTab)
			team1NameLabel = GuiLabel.create(startX, 30, 50, 20, "Tag:", false, mainTab)
			team1Name = GuiEdit.create(startX + 60, 30, 120, 20, tn1, false, mainTab)
			team1ColorLabel = GuiLabel.create(startX, 55, 50, 20, "Color:", false, mainTab)
			team1Color = GuiEdit.create(startX + 60, 55, 90, 20, tc1, false, mainTab)
			team1ColorPicker = GuiButton.create(startX + 150, 55, 30, 20, "#", false, mainTab)
			team1PointsLabel = GuiLabel.create(startX, 80, 50, 20, "Points:", false, mainTab)
			team1removeButton = GuiButton.create(startX + 60, 80, 30, 20, "-", false, mainTab)
			team1addButton = GuiButton.create(startX + 150, 80, 30, 20, "+", false, mainTab)
			team1Points = GuiEdit.create(startX + 90, 80, 60, 20, tp1, false, mainTab)
			team1Points:setReadOnly(true)
			team1Players = GuiGridList.create(startX, 110, 180, 130, false, mainTab)
			team1Players:addColumn("Players", 0.85)

			if team1 and isElement(team1) then
				for i, v in ipairs(team1:getPlayers()) do
					team1Players:addRow(newNick(v:getName()))
				end
			end

			team1SaveButton = GuiButton.create(startX, 240, 180, 20, "Save", false, mainTab)

			team2Label = GuiLabel.create(startX + 300, 5, 45, 20, "Team 2:", false, mainTab)
			team2NameLabel = GuiLabel.create(startX + 300, 30, 50, 20, "Tag:", false, mainTab)
			team2Name = GuiEdit.create(startX + 360, 30, 120, 20, tn2, false, mainTab)
			team2ColorLabel = GuiLabel.create(startX + 300, 55, 50, 20, "Color:", false, mainTab)
			team2Color = GuiEdit.create(startX + 360, 55, 90, 20, tc2, false, mainTab)
			team2ColorPicker = GuiButton.create(startX + 450, 55, 30, 20, "#", false, mainTab)
			team2PointsLabel = GuiLabel.create(startX + 300, 80, 50, 20, "Points:", false, mainTab)
			team2removeButton = GuiButton.create(startX + 360, 80, 30, 20, "-", false, mainTab)
			team2addButton = GuiButton.create(startX + 450, 80, 30, 20, "+", false, mainTab)
			team2Points = GuiEdit.create(startX + 390, 80, 60, 20, tp2, false, mainTab)
			team2Points:setReadOnly(true)
			team2Players = GuiGridList.create(startX + 300, 110, 180, 130, false, mainTab)
			team2Players:addColumn("Players", 0.85)

			if team2 and isElement(team2) then
				for i, v in ipairs(team2:getPlayers()) do
					team2Players:addRow(newNick(v:getName()))
				end
			end

			team2SaveButton = GuiButton.create(startX+300, 240, 180, 20, "Save", false, mainTab)
		else
			local startX = 10
			team1Label = GuiLabel.create(startX, 5, 45, 20, "Team 1:", false, mainTab)
			team1NameLabel = GuiLabel.create(startX, 30, 50, 20, "Tag:", false, mainTab)
			team1Name = GuiEdit.create(startX + 60, 30, 120, 20, tn1, false, mainTab)
			team1ColorLabel = GuiLabel.create(startX, 55, 50, 20, "Color:", false, mainTab)
			team1Color = GuiEdit.create(startX + 60, 55, 90, 20, tc1, false, mainTab)
			team1ColorPicker = GuiButton.create(startX + 150, 55, 30, 20, "#", false, mainTab)
			team1PointsLabel = GuiLabel.create(startX, 80, 50, 20, "Points:", false, mainTab)
			team1removeButton = GuiButton.create(startX + 60, 80, 30, 20, "-", false, mainTab)
			team1addButton = GuiButton.create(startX + 150, 80, 30, 20, "+", false, mainTab)
			team1Points = GuiEdit.create(startX + 90, 80, 60, 20, tp1, false, mainTab)
			team1Points:setReadOnly(true)
			team1Players = GuiGridList.create(startX, 110, 180, 130, false, mainTab)
			team1Players:addColumn("Players", 0.85)

			if team1 and isElement(team1) then
				for i, v in ipairs(team1:getPlayers()) do
					team1Players:addRow(newNick(v:getName()))
				end
			end

			team1SaveButton = GuiButton.create(startX, 240, 180, 20, "Save", false, mainTab)

			team2Label = GuiLabel.create(startX + 190, 5, 45, 20, "Team 2:", false, mainTab)
			team2NameLabel = GuiLabel.create(startX + 190, 30, 50, 20, "Tag:", false, mainTab)
			team2Name = GuiEdit.create(startX + 250, 30, 120, 20, tn2, false, mainTab)
			team2ColorLabel = GuiLabel.create(startX + 190, 55, 50, 20, "Color:", false, mainTab)
			team2Color = GuiEdit.create(startX + 250, 55, 90, 20, tc2, false, mainTab)
			team2ColorPicker = GuiButton.create(startX + 340, 55, 30, 20, "#", false, mainTab)
			team2PointsLabel = GuiLabel.create(startX + 190, 80, 50, 20, "Points:", false, mainTab)
			team2removeButton = GuiButton.create(startX + 250, 80, 30, 20, "-", false, mainTab)
			team2addButton = GuiButton.create(startX + 340, 80, 30, 20, "+", false, mainTab)
			team2Points = GuiEdit.create(startX + 280, 80, 60, 20, tp2, false, mainTab)
			team2Points:setReadOnly(true)
			team2Players = GuiGridList.create(startX + 190, 110, 180, 130, false, mainTab)
			team2Players:addColumn("Players", 0.85)

			if team2 and isElement(team2) then
				for i, v in ipairs(team2:getPlayers()) do
					team2Players:addRow(newNick(v:getName()))
				end
			end

			team2SaveButton = GuiButton.create(startX + 190, 240, 180, 20, "Save", false, mainTab)

			team3Label = GuiLabel.create(startX + 380, 5, 45, 20, "Team 3:", false, mainTab)
			team3NameLabel = GuiLabel.create(startX + 380, 30, 50, 20, "Tag:", false, mainTab)
			team3Name = GuiEdit.create(startX + 440, 30, 120, 20, tn3, false, mainTab)
			team3ColorLabel = GuiLabel.create(startX + 380, 55, 50, 20, "Color:", false, mainTab)
			team3Color = GuiEdit.create(startX + 440, 55, 90, 20, tc3, false, mainTab)
			team3ColorPicker = GuiButton.create(startX + 530, 55, 30, 20, "#", false, mainTab)
			team3PointsLabel = GuiLabel.create(startX + 380, 80, 50, 20, "Points:", false, mainTab)
			team3removeButton = GuiButton.create(startX + 440, 80, 30, 20, "-", false, mainTab)
			team3addButton = GuiButton.create(startX + 530, 80, 30, 20, "+", false, mainTab)
			team3Points = GuiEdit.create(startX + 470, 80, 60, 20, tp3, false, mainTab)
			team3Points:setReadOnly(true)
			team3Players = GuiGridList.create(startX + 380, 110, 180, 130, false, mainTab)
			team3Players:addColumn("Players", 0.85)

			if team3 and isElement(team3) then
				for i, v in ipairs(team3:getPlayers()) do
					team3Players:addRow(newNick(v:getName()))
				end
			end

			team3SaveButton = GuiButton.create(startX + 380, 240, 180, 20, "Save", false, mainTab)
		end

		-- #MAPS TAB
			searchMaps = GuiEdit.create(5, 5, w/2.3, 20, "", false, mapsTab)
			allMapsGridList = GuiGridList.create(5, 25, w/2.3, 235, false, mapsTab)
			allMapsGridList:addColumn("Maps", 0.85)

			for i, v in ipairs(mapsTable) do
				local row = allMapsGridList:addRow(v.name)
				allMapsGridList:setItemData(row, 1, v.map)
			end

			choosenMapsGridList = GuiGridList.create(50+w/2.3, 5, w/2.3, 235, false, mapsTab)
			choosenMapsUpdateButton = GuiButton.create(50+w/2.3, 240, w/2.3, 20, "Update maps", false, mapsTab)
			choosenMapsGridList:addColumn("Choosen maps", 0.85)

			for i, v in ipairs(choosenMapsTable) do
				local row = choosenMapsGridList:addRow(v.name)
				choosenMapsGridList:setItemData(row, 1, v.map)
			end

		isWindow = true
		showCursor(true)
		guiSetInputEnabled(true)
	end
end
addEvent("openSettingsWindow", true)
addEventHandler("openSettingsWindow", root, window)

addEventHandler("onClientGUIChanged", root,
function()
	if source == searchMaps then
		local text = (source:getText()):lower()
		allMapsGridList:clear()
		for i, v in ipairs(mapsTable) do
			if string.find((v.name):lower(), text, 1, true) then
				local row = allMapsGridList:addRow(v.name)
				allMapsGridList:setItemData(row, 1, v.map)
			end
		end
	end
end)

addEventHandler("onClientGUIClick", root,
function()
	if source == team1ColorPicker then
		openPicker(team1ColorPicker, tc1, tn1.."  color")
	elseif source == team2ColorPicker then
		openPicker(team2ColorPicker, tc2, tn2.."  color")
	elseif source == team3ColorPicker then
		openPicker(team3ColorPicker, tc3, tn3.."  color")
	end

	if source == team1removeButton then
		if team1Points:getText() - 1 >= 0 then
			team1Points:setText(team1Points:getText() - 1)
		end
	elseif source == team2removeButton then
		if team2Points:getText() - 1 >= 0 then
			team2Points:setText(team2Points:getText() - 1)
		end
	elseif source == team3removeButton then
		if team3Points:getText() - 1 >= 0 then
			team3Points:setText(team3Points:getText() - 1)
		end
	elseif source == team1addButton then
		team1Points:setText(team1Points:getText() + 1)
	elseif source == team2addButton then
		team2Points:setText(team2Points:getText() + 1)
	elseif source == team3addButton then
		team3Points:setText(team3Points:getText() + 1)
	end

	
	if source == team1SaveButton then
		local name, color, points = team1Name:getText(), team1Color:getText(), team1Points:getText()
		if getColorFromString(color) and string.len(color) == 7 then
			triggerServerEvent("updateTeamSettings", localPlayer, 1, name, color, points)
		else
			outputChatBox("Wrong color", 255, 0, 0)
		end
	elseif source == team2SaveButton then
		local name, color, points = team2Name:getText(), team2Color:getText(), team2Points:getText()
		if getColorFromString(color) and string.len(color) == 7 then
			triggerServerEvent("updateTeamSettings", localPlayer, 2, name, color, points)
		else
			outputChatBox("Wrong color", 255, 0, 0)
		end
	elseif source == team3SaveButton then
		local name, color, points = team3Name:getText(), team3Color:getText(), team3Points:getText()
		if getColorFromString(color) and string.len(color) == 7 then
			triggerServerEvent("updateTeamSettings", localPlayer, 3, name, color, points)
		else
			outputChatBox("Wrong color", 255, 0, 0)
		end
	end

	if source == choosenMapsUpdateButton then
		local count = choosenMapsGridList:getRowCount()
		if count > 0 then
			if count == 2 or count == 4 then
				local maps = {}
				for i = 0, count-1 do
					local text = choosenMapsGridList:getItemText(i, 1)
					local data = choosenMapsGridList:getItemData(i, 1)
					maps[i+1] = {["map"] = data, ["name"] = text}
				end
				triggerServerEvent("updateChoosenMaps", localPlayer, maps, 0)
			else
				if isTeam3 then
					if count ~= 4 then
						outputChatBox("[ERROR] #FFFFFFMaps count should be #FF00004#FFFFFF.", 255, 0, 0, true)
					end
				else
					outputChatBox("[ERROR] #FFFFFFMaps count should be #FF00002 #FFFFFFor #FF00004#FFFFFF.", 255, 0, 0, true)
				end
			end
		else
			triggerServerEvent("updateChoosenMaps", localPlayer, {}, 0)
		end
	end
end)

addEventHandler("onClientGUIDoubleClick", root,
function(button)
	if source == allMapsGridList then
		if button == "left" then
			local item = source:getSelectedItem()
			local text = source:getItemText(item, 1)
			local data = source:getItemData(item, 1)
			local row = choosenMapsGridList:addRow(text)
			choosenMapsGridList:setItemData(row, 1, data)
		end
	elseif source == choosenMapsGridList then
		if button == "left" then
			local item = source:getSelectedItem()
			source:removeRow(item)
		end
	end
end)

addEvent("onColorPickerOK")
addEventHandler("onColorPickerOK", root,
function(element, color)
	if element == team1ColorPicker then
		team1Color:setText(color)
	elseif element == team2ColorPicker then
		team2Color:setText(color)
	elseif element == team3ColorPicker then
		team3Color:setText(color)
	end
end)

addEvent("onColorPickerChange")
addEventHandler("onColorPickerChange", root,
function(element, color, r, g, b)
	local vehicle = localPlayer:getOccupiedVehicle()
	if isElement(vehicle) then
		setVehicleColor(vehicle, r, g, b)
	end
end)

triggerServerEvent("requestClanWarSettings", localPlayer)
triggerServerEvent("requestMaps", localPlayer)

function _setTime(cmd, h, m)
	if tonumber(h) ~= nil then
		if tonumber(h) > 23 then
			h = "00"
		elseif tonumber(h) < 0 then
			h = "00"
		end
		if tonumber(m) ~= nil then
			if tonumber(m) > 59 then
				m = "59"
			elseif tonumber(m) < 0 then
				m = "00"
			end
			setTime(h, m)
			setMinuteDuration(6000000)
			local m = string.format("%02d", m)
			outputChatBox("#444444[Server] #FFFFFFTime set to "..h..":"..m..".", 255, 255, 255, true)
			cst = true
			cst_h = tonumber(h)
			cst_m = tonumber(m)
		else
			setTime(h, 0)
			setMinuteDuration(6000000)
			outputChatBox("#444444[Server] #FFFFFFTime set to "..h..":".."00"..".", 255, 255, 255, true)
			cst = true
			cst_h = tonumber(h)
			cst_m = 0
		end
	else
		if cst then
			outputChatBox("#444444[Server] #FFFFFFTime set by the map.", 255, 255, 255, true)			
			cst = false
			cst_h, cst_m = nil, nil
			setTime(cst_def_h or 12, cst_def_m or 0)
		end
	end
end
addCommandHandler("st", _setTime)
addCommandHandler("cst", _setTime)

function _setWeather(cmd, id)
	if tonumber(id) ~= nil then
		if tonumber(id) > 255 then
			id = 255
		elseif tonumber(id) < 0 then
			id = 0
		end
		setWeather(id)
		outputChatBox("#444444[Server] #FFFFFFWeather set to "..id..".", 255, 255, 255, true)
		csw = true
		csw_id = tonumber(id)
	else
		if csw then
			outputChatBox("#444444[Server] #FFFFFFWeather set by the map.", 255, 255, 255, true)
			csw = false
			csw_id = nil
			setWeather(csw_def_id or 0)
		end
	end
end
addCommandHandler("sw", _setWeather)
addCommandHandler("csw", _setWeather)

addEvent("onClientMapStarting", true)
addEventHandler("onClientMapStarting", root,
function()
	cst_def_h, cst_def_m = getTime()
	csw_def_id = getWeather()
	if cst then
		setTime(cst_h, cst_h)
		setMinuteDuration(6000000)
	end
	if csw then
		setWeather(csw_id)
	end
end, true, "low")

function onPreFunction(sourceResource)
	local resname = sourceResource and sourceResource:getName()
	if resname ~= "checker" then return "skip" end
end
addDebugHook("preFunction", onPreFunction, {"addDebugHook"})

-- Kill System

local clearKillTime = 8

addEventHandler("onClientVehicleCollision", root,
function(hitElement)
	if hitElement then
		theCar = getPedOccupiedVehicle(getLocalPlayer())
		if theCar then
			if getElementType(hitElement) == "vehicle" and source == theCar then
				local hitPlayer = getVehicleOccupant(hitElement)
				if hitPlayer then
					local myKiller = getElementData(getLocalPlayer(), "myKiller")
					if isTimer(clearKillerTimer) then killTimer(clearKillerTimer) end
					if myKiller == nil or myKiller == hitPlayer then
						setElementData(getLocalPlayer(), "myKiller", hitPlayer)
						clearKillerTimer = setTimer(clearKill, clearKillTime*1000, 1)
					elseif myKiller ~= hitPlayer then
						setElementData(getLocalPlayer(), "myKiller", hitPlayer)
						setElementData(getLocalPlayer(), "myAssister", myKiller)
						clearKillerTimer = setTimer(clearKill, clearKillTime*1000, 1)
					end
				end
			end
		end
	end
end)

function clearKill()
	local theCar = getPedOccupiedVehicle(getLocalPlayer())
	if not theCar then return end
	if isVehicleOnGround(theCar) == true and isElementInWater(theCar) == false and getElementHealth(theCar)>250 then
		setElementData(getLocalPlayer(), "myKiller", nil)
		setElementData(getLocalPlayer(), "myAssister", nil)
	else
		setTimer(clearKill, 300, 1)
	end
end

	