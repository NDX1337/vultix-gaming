executeSQLQuery("CREATE TABLE IF NOT EXISTS maps_commands (short TEXT, full TEXT, resource TEXT)")
executeSQLQuery("CREATE TABLE IF NOT EXISTS wizu_teams (tag TEXT, full_name TEXT)")

-- Kills

local killsData = {}

local r, g, b = getColorFromString(get("team1Color") or "#FFFF00")
local r1, g1, b1 = getColorFromString(get("team2Color") or "#FF0000")

local teamS = Team("Spectators", 200, 200, 200)

local selected_1 = executeSQLQuery("SELECT tag,full_name FROM wizu_teams WHERE tag=?", get("team1Name"))
if #selected_1 ~= 0 then
	local tag = selected_1[1]["tag"]
	local full_name = selected_1[1]["full_name"]
	team1 = Team(full_name or "HHX", r, g, b)
	team1:setData("tag", tag)
else
	team1 = Team(get("team1Name") or "HHX", r, g, b)
	team1:setData("tag", get("team1Name"))
end

local selected_2 = executeSQLQuery("SELECT tag,full_name FROM wizu_teams WHERE tag=?", get("team2Name"))
if #selected_2 ~= 0 then
	local tag = selected_2[1]["tag"]
	local full_name = selected_2[1]["full_name"]
	team2 = Team(full_name or "HHX", r1, g1, b1)
	team2:setData("tag", tag)
else
	team2 = Team(get("team2Name") or "HHX", r1, g1, b1)
	team2:setData("tag", get("team2Name"))
end

local team1Members = {}
local team2Members = {}

team1:setData("state", 0)
team2:setData("state", 0)

local scriptType = "ClanWar"
local clanWarState, currentMapState, currentMapMode = "Free", "Running", "Destruction derby"
local currentMapName = ""
local team1Points, team2Points, team3Points = 0, 0, 0
local rounds, roundsLeft = 20, 20
local winnerTeam
local isSomeoneWon = false
local isStoped = false

setGameType(team1:getName()..":"..team1Points.." |20| "..team2:getName()..":"..team2Points)

local spectatorsChat = toboolean(get("specChat"))
local spectatorsKill = toboolean(get("specKill"))
local autoPoints = toboolean(get("autoPoints"))
local isAir = toboolean(get("inAir"))
local isWater = toboolean(get("inWater"))

function canPlayerChat(player)
	if not spectatorsChat and player:getTeam() == teamS then
		return false
	end
	return true
end

local isTeam3 = false
local isRedoPoll, pollTeam, pollNick = false

local choosenMapsTable = {}

local teleports = {}

function setTeamName(player, cmd, team, name)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if name then
			local byPlayer = newNick(player:getName())
			local text, cTeam, teamName, teamColor = "", getEditedTeam(team)
			local selected = executeSQLQuery("SELECT full_name FROM wizu_teams WHERE tag=?", name)

			if isElement(cTeam) then
				if #selected ~= 0 then
					local full_name = selected[1]["full_name"]
					teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "\""..teamColor..teamName.."#FFFFFF\" was changed to \""..teamColor..full_name.."#FFFFFF\" by "
																								..byPlayer
					cTeam:setName(full_name)
					cTeam:setData("tag", name)
				else
					teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "\""..teamColor..teamName.."#FFFFFF\" was changed to \""..teamColor..name.."#FFFFFF\" by "
																								..byPlayer
					cTeam:setName(name)
					cTeam:setData("tag", name)
				end
			end
			outputChatBox(text, root, 255, 255, 255, true)
			exports["ae-sync"]:sendDiscordMessage(text)
			outputServerLog("CLANWAR: "..newNick(text))
			sendClanWarSettings()
		else
			outputChatBox("/stn 1 HHX", player)
		end
	end
end
addCommandHandler("stn", setTeamName)

function drawCW(player, cmd, team, name)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if player:getTeam() == team1 or player:getTeam() == team2 then
			if team1Points >= 10 and team1Points == team2Points and (team1Points-10)%2 == 0 then
				local msg = "[CW] #ffffff"..getPlayerName(player).."#ffffff has ended this match as a draw with score "..team1Points.."-"..team1Points.."."
				outputChatBox(msg, root, 255, 0, 0, true)
				exports["ae-sync"]:sendDiscordMessage(msg)
				local killsText = showKills()
				exports["ae-sync"]:sendCWScore({type = "score", scoreData = {{name = getEditedTeam("1"):getName(), points = team1Points, players = teamToStringPlayers(getEditedTeam("1"))}, {name = getEditedTeam("2"):getName(), points = team2Points, players = teamToStringPlayers(getEditedTeam("2"))}}, killsData = killsText})
				resetKills()
			else
				outputChatBox("[CW] #ffffffYou can only draw when score is 10-10, 12-12, etc.", player, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("draw", drawCW)

function setTeamColor(player, cmd, team, color)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if (color and string.len(color) == 6 and getColorFromString("#"..color))
		or (color and string.len(color) == 7 and getColorFromString(color)) then
			if string.len(color) == 7 then color = color:sub(2, 7) end
			local byPlayer = newNick(player:getName())
			local text, cTeam, teamName, teamColor = "", getEditedTeam(team)
			if isElement(cTeam) then
				teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
				text = "\""..teamColor..teamName.."#FFFFFF\" color was changed to \"#"..color..color:upper()
																					.."#FFFFFF\" by "..byPlayer
				cTeam:setColor(getColorFromString("#"..color))
			end
			outputChatBox(text, root, 255, 255, 255, true)
			outputServerLog("CLANWAR: "..newNick(text))
			sendClanWarSettings()
		else
			outputChatBox("/stc 1 FFFF00", player)
		end
	end
end
addCommandHandler("stc", setTeamColor)

function addPoint(player, cmd, team)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if team then
			if setPointsToTeam(team, "add") then
				local byPlayer, text = newNick(player:getName()), ""
				local tn1, tn2 = team1:getName(), team2:getName()
				local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
				if not isTeam3 then
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF ("..team1Points.." : "..team2Points..") "..tc2..tn2
				else
					local tn3, tc3 = team3:getName(), RGBToHex(team3:getColor())
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF: "..team1Points.."#FFFFFF || "..tc2..tn2.."#FFFFFF: "
														..team2Points.."#FFFFFF || "..tc3..tn3.."#FFFFFF: "..team3Points
				end
				outputChatBox(text, root, 255, 255, 255, true)
				exports["ae-sync"]:sendDiscordMessage(text)
				outputServerLog("CLANWAR: "..newNick(text))
				sendClanWarSettings()
			end
		else
			outputChatBox("/ap 1", player)
		end
	end
end
addCommandHandler("ap", addPoint)

function removePoint(player, cmd, team)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if team then
			if setPointsToTeam(team, "delete") then
				local byPlayer, text = newNick(player:getName()), ""
				local tn1, tn2 = team1:getName(), team2:getName()
				local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
				if not isTeam3 then
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF ("..team1Points.." : "..team2Points..") "..tc2..tn2
				else
					local tn3, tc3 = team3:getName(), RGBToHex(team3:getColor())
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF: "..team1Points.."#FFFFFF || "..tc2..tn2.."#FFFFFF: "
														..team2Points.."#FFFFFF || "..tc3..tn3.."#FFFFFF: "..team3Points
				end
				outputChatBox(text, root, 255, 255, 255, true)
				exports["ae-sync"]:sendDiscordMessage(text)
				outputServerLog("CLANWAR: "..newNick(text))
				sendClanWarSettings()
			end
		else
			outputChatBox("/dp 1", player)
		end
	end
end
addCommandHandler("dp", removePoint)

function setPoints(player, cmd, team, number)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if team and tonumber(number) ~= nil and tonumber(number) >= 0 then
			if setPointsToTeam(team, "set", number) then
				local byPlayer, text = newNick(player:getName()), ""
				local tn1, tn2 = team1:getName(), team2:getName()
				local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
				if not isTeam3 then
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF ("..team1Points.." : "..team2Points..") "..tc2..tn2
				else
					local tn3, tc3 = team3:getName(), RGBToHex(team3:getColor())
					text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF: "..team1Points.."#FFFFFF || "..tc2..tn2.."#FFFFFF: "
														..team2Points.."#FFFFFF || "..tc3..tn3.."#FFFFFF: "..team3Points
				end
				outputChatBox(text, root, 255, 255, 255, true)
				exports["ae-sync"]:sendDiscordMessage(text)
				outputServerLog("CLANWAR: "..newNick(text))
				sendClanWarSettings()
				if team1Points == 0 and team2Points == 0 then
					resetKills()
				end
			end
		else
			outputChatBox("/sp 1 5", player)
		end
	end
end
addCommandHandler("sp", setPoints)

function resetPoints(player, cmd)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if clanWarState == "Live" then return outputChatBox("[CW] You can't do that while the CW is LIVE.", player, 255, 255, 255, true) end
		if setPointsToTeam(_, "reset") then
			local byPlayer, text = newNick(player:getName()), ""
			local tn1, tn2 = team1:getName(), team2:getName()
			local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
			if not isTeam3 then
				text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF ("..team1Points.." : "..team2Points..") "..tc2..tn2
			else
				local tn3, tc3 = team3:getName(), RGBToHex(team3:getColor())
				text = "("..byPlayer..") "..tc1..tn1.."#FFFFFF: "..team1Points.."#FFFFFF || "..tc2..tn2.."#FFFFFF: "
													..team2Points.."#FFFFFF || "..tc3..tn3.."#FFFFFF: "..team3Points
			end
			outputChatBox(text, root, 255, 255, 255, true)
			exports["ae-sync"]:sendDiscordMessage(text)
			exports["ae-sync"]:resetStreak()
			outputServerLog("CLANWAR: "..newNick(text))
			sendClanWarSettings()
			resetKills()
		end
	end
end
addCommandHandler("rp", resetPoints)

addCommandHandler("specchat",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		spectatorsChat = not spectatorsChat
		local byPlayer, message = newNick(player:getName()), ""
		if spectatorsChat then
			message = "Spectators chat was #00FF00enabled #FFFFFFby "..byPlayer
		else
			message = "Spectators chat was #FF0000disabled #FFFFFFby "..byPlayer
		end
		outputChatBox(message, root, 255, 255, 255, true)
		exports["ae-sync"]:sendDiscordMessage(message)
		outputServerLog("CLANWAR: "..newNick(message))
	end
end)

addCommandHandler("speckill",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		spectatorsKill = not spectatorsKill
		local byPlayer, message = newNick(player:getName()), ""
		if spectatorsKill then
			message = "Spectators auto-kill was #00FF00enabled #FFFFFFby "..byPlayer
		else
			message = "Spectators auto-kill was #FF0000disabled #FFFFFFby "..byPlayer
		end
		outputChatBox(message, root, 255, 255, 255, true)
		exports["ae-sync"]:sendDiscordMessage(message)
		outputServerLog("CLANWAR: "..newNick(message))
	end
end)

addCommandHandler("changetype",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		if not isTeam3 then
			local byPlayer = newNick(player:getName())
			if scriptType == "ClanWar" then
				scriptType = "PvP"
				rounds = 10
				outputChatBox("Match mode was changed to \"#FF0000PvP#FFFFFF\" by "..byPlayer, root, 255, 255, 255, true)
				outputServerLog("CLANWAR: Match mode was changed to PvP by "..byPlayer)
			elseif scriptType == "PvP" then
				scriptType = "ClanWar"
				rounds = 20
				outputChatBox("Match mode was changed to \"#00FF00Clan War#FFFFFF\" by "..byPlayer, root, 255, 255, 255, true)
				outputServerLog("CLANWAR: Match mode was changed to Clan War by "..byPlayer)
			end
			sendClanWarSettings()
		end
	end
end)

addCommandHandler("autopoints",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		autoPoints = not autoPoints
		local byPlayer, message = newNick(player:getName()), ""
		if autoPoints then
			message = "Count points automatically was #00FF00enabled #FFFFFFby "..byPlayer
		else
			message = "Count points automatically was #FF0000disabled #FFFFFFby "..byPlayer
		end
		outputChatBox(message, root, 255, 255, 255, true)
		exports["ae-sync"]:sendDiscordMessage(message)
		outputServerLog("CLANWAR: "..newNick(message))
	end
end)

addCommandHandler("team3",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		local byPlayer = newNick(player:getName())
		if not isTeam3 then
			if isRedoPoll then
				stopRedoPoll()
			end
			team3 = Team("Team3", 0, 0, 255)
			team3Points = 0
			team3:setData("tag", "Team3")
			team3:setData("state", 0)
			outputChatBox("Team3 was #00FF00added #FFFFFFby "..byPlayer, root, 255, 255, 255, true)
			isTeam3 = true
			outputServerLog("CLANWAR: Team3 was added by "..byPlayer)
			scriptType = "ClanWar"
			rounds = 20
			getChoosenMaps({}, 1)
		else
			team3:destroy()
			outputChatBox("Team3 was #FF0000removed #FFFFFFby "..byPlayer, root, 255, 255, 255, true)
			isTeam3 = false
			outputServerLog("CLANWAR: Team3 was removed by "..byPlayer)
		end
		sendClanWarSettings()
	end
end)

function getEditedTeam(team)
	checkTeams()
	local cTeam = false
	if isElement(team) then
		if team == team1 then
			cTeam = team1
		elseif team == team2 then
			cTeam = team2
		end
		if isTeam3 and team == team3 then
			cTeam = team3
		end
	else
		if team == "1" then
			cTeam = team1
		elseif team == "2" then
			cTeam = team2
		end
		if isTeam3 and team == "3" then
			cTeam = team3
		end
	end
	return cTeam
end

function setPointsToTeam(team, move, points)
	checkTeams()
	if (move == "add") then
		local teamToAdd = isElement(team) and (team == team1 and "1" or "2") or team
		local winnerPoints, otherPoints
		if teamToAdd == "1" then
			winnerPoints, otherPoints = team1Points, team2Points
		else
			winnerPoints, otherPoints = team2Points, team1Points
		end
		local winningPoint = false
		if winnerPoints == 10 and otherPoints < 10 then
			winningPoint = true
		elseif winnerPoints > 11 and otherPoints >= 10 then
			local rounds = (winnerPoints-10)+(otherPoints-10)
			local extraRound = (rounds-rounds%4)/4
			if winnerPoints+1 == 13+extraRound*2 then
				winningPoint = true
			end
		end
		if winningPoint then
			local killsText = showKills()
			if teamToAdd == "1" then
				exports["ae-sync"]:sendCWScore({type = "score", scoreData = {{name = getEditedTeam("1"):getName(), points = team1Points+1, players = teamToStringPlayers(getEditedTeam("1"))}, {name = getEditedTeam("2"):getName(), points = team2Points, players = teamToStringPlayers(getEditedTeam("2"))}}, killsData = killsText})
			else
				exports["ae-sync"]:sendCWScore({type = "score", scoreData = {{name = getEditedTeam("2"):getName(), points = team2Points+1, players = teamToStringPlayers(getEditedTeam("2"))}, {name = getEditedTeam("1"):getName(), points = team1Points, players = teamToStringPlayers(getEditedTeam("1"))}}, killsData = killsText})
			end
			resetKills()
		end
	end
	if isElement(team) then
		if team == team1 then
			if move == "add" then
				team1Points = team1Points + 1
				team1:setData("state", team1Points)
			end
		elseif team == team2 then
			if move == "add" then
				team2Points = team2Points + 1
				team2:setData("state", team2Points)
			end
		elseif isTeam3 and team == team3 then
			if move == "add" then
				team3Points = team3Points + 1
				team3:setData("state", team3Points)
			end
		end
	else
		if team == "1" then
			if move == "add" then
				team1Points = team1Points + 1
			elseif move == "delete" then
				if team1Points - 1 < 0 then
					return false
				end
				team1Points = team1Points - 1
			elseif move == "set" then
				team1Points = tonumber(points)
			end
			team1:setData("state", team1Points)
			return true
		elseif team == "2" then
			if move == "add" then
				team2Points = team2Points + 1
			elseif move == "delete" then
				if team2Points - 1 < 0 then
					return false
				end
				team2Points = team2Points - 1
			elseif move == "set" then
				team2Points = tonumber(points)
			end
			team2:setData("state", team2Points)
			return true
		end
		if isTeam3 and team == "3" then
			if move == "add" then
				team3Points = team3Points + 1
			elseif move == "delete" then
				if team3Points - 1 < 0 then
					return false
				end
				team3Points = team3Points - 1
			elseif move == "set" then
				team3Points = tonumber(points)
			end
			team3:setData("state", team3Points)
			return true
		end
	end
	if move == "reset" then
		team1Points = 0
		team2Points = 0
		team1:setData("state", team1Points)
		team2:setData("state", team2Points)
		if isTeam3 then
			team3Points = 0
			team3:setData("state", team3Points)
		end
		return true
	end
end

function checkACL(player, group)
	if getElementType(player) == "console" then
		return true
	else
		local accName = (player:getAccount()):getName()
		if ACLGroup.get(group):doesContainObject("user."..accName) then
			return true
		end
		return false
	end
end

function checkTeams()
	if not isElement(teamS) or not isElement(team1) or not isElement(team2) then
		clearTeams()
		teamS = Team("Spectators", 200, 200, 200)
		team1 = Team(get("team1Tag") or "HHX", r, g, b)
		team2 = Team(get("team2Tag") or "CW", r1, g1, b1)
		sendClanWarSettings()
	end
	if isTeam3 then
		if not isElement(teamS) or not isElement(team1) or not isElement(team2) or not isElement(team3) then
			clearTeams()
			teamS = Team("Spectators", 200, 200, 200)
			team1 = Team(get("team1Tag") or "HHX", r, g, b)
			team2 = Team(get("team2Tag") or "CW", r1, g1, b1)
			team3 = Team("Team3", 0, 0, 255)
			sendClanWarSettings()
		end
	end
end

function clearTeams()
	if isElement(teamS) then
		teamS:destroy()
		teamS = nil
	end
	if isElement(team1) then
		team1:destroy()
		team1 = nil
	end
	if isElement(team2) then
		team2:destroy()
		team2 = nil
	end
	if isElement(team3) then
		team3:destroy()
		team3 = nil
	end
end

function checkPlayerTeam(player, team)
	local nick = newNick(player:getName())
	local teamName = team:getData("tag") or team:getName()
	if nick:find(teamName, 1, true) then
		return true
	end
	return false
end

function assignToTeam()
	checkTeams()
	for _,v in ipairs(Element.getAllByType("player")) do
		if isTeam3 then
			if checkPlayerTeam(v, team1) then
				v:setTeam(team1)
			elseif checkPlayerTeam(v, team2) then
				v:setTeam(team2)
			elseif checkPlayerTeam(v, team3) then
				v:setTeam(team3)
			else
				if team1:getData("tag") == "*" or team1:getName() == "*" then
					v:setTeam(team1)
				elseif team2:getData("tag") == "*" or team2:getName() == "*" then
					v:setTeam(team2)
				elseif team3:getData("tag") == "*" or team3:getName() == "*" then
					v:setTeam(team3)
				else
					v:setTeam(teamS)
				end
			end
		else
			if checkPlayerTeam(v, team1) then
				v:setTeam(team1)
			elseif checkPlayerTeam(v, team2) then
				v:setTeam(team2)
			else
				if team1:getData("tag") == "*" or team1:getName() == "*" then
					v:setTeam(team1)
				elseif team2:getData("tag") == "*" or team2:getName() == "*" then
					v:setTeam(team2)
				else
					v:setTeam(teamS)
				end
			end			
		end
		carTeamColor(v)
	end
end

function carTeamColor(player)
	if player and isElement(player) and player:getType() == "player" then
		if not player:getData("isSettingWindowOpened") then
			local vehicle = player:getOccupiedVehicle()
			if isElement(vehicle) and player:getOccupiedVehicleSeat() == 0 then
				local team = player:getTeam()
				if isElement(team) then
					local r, g, b = team:getColor()
						vehicle:setColor(r, g, b, r, g, b, r, g, b, r, g, b)
						vehicle:setOverrideLights(0)
						vehicle:setCollisionsEnabled(true)
						vehicle:setEngineState(true)
						if vehicle:getAlpha() == 0 then
							vehicle:setAlpha(255)
							player:setAlpha(255)
						end
					if team == teamS then
						if clanWarState == "Live" and currentMapState ~= "Running" then
							vehicle:setOverrideLights(1)
							vehicle:setAlpha(0)
							vehicle:setCollisionsEnabled(false)
							vehicle:setEngineState(false)
							player:setAlpha(0)
						else
							vehicle:setOverrideLights(0)
							vehicle:setCollisionsEnabled(true)
							vehicle:setEngineState(true)
							if vehicle:getAlpha() == 0 then
								vehicle:setAlpha(255)
								player:setAlpha(255)
							end
						end
					end
				end
			end
		end
	end
end

function sendClanWarSettings()
	local settings = {}
	checkTeams()

	settings["team1"] = team1
	settings["tn1"] = team1:getData("tag") or team1:getName()
	settings["tc1"] = RGBToHex(team1:getColor())
	settings["tp1"] = team1Points
	
	settings["team2"] = team2
	settings["tn2"] = team2:getData("tag") or team2:getName()
	settings["tc2"] = RGBToHex(team2:getColor())
	settings["tp2"] = team2Points

	settings["clanWarState"] = clanWarState
	settings["hudKey"] = get("cwHudKey")

	settings["rounds"] = rounds

	if isSomeoneWon then
		settings["isSomeoneWon"] = true
		settings["winnerTeam"] = winnerTeam
	end

	if isTeam3 then
		settings["team3"] = team3
		settings["tn3"] = team3:getData("tag") or team3:getName()
		settings["tc3"] = RGBToHex(team3:getColor())
		settings["tp3"] = team3Points
		roundsLeft = roundsLeft - team3Points
		settings["roundsLeft"] = roundsLeft
		setGameType(team1:getData("tag")..":"..team1Points.." || "..team2:getData("tag")..":"..team2Points..
														" || "..team3:getData("tag")..": "..team3Points)
	else
		roundsLeft = rounds - (team1Points + team2Points)
		settings["roundsLeft"] = roundsLeft
		local left = roundsLeft
		if roundsLeft <= 0 then left = 0 end
		setGameType(team1:getData("tag")..":"..team1Points.." |"..left.."| "..team2:getData("tag")..":"..team2Points)
	end
	

	triggerClientEvent(root, "receiveClanWarSettings", root, isTeam3, settings)

	triggerClientEvent(root, "receiveMaps", root, _, choosenMapsTable)
	local liveData = getDataForSync()
	if not lastData or lastData ~= liveData then
		exports["ae-sync"]:updateCWToAll(true, liveData)
		lastData = liveData
	end
end
addEvent("requestClanWarSettings", true)
addEventHandler("requestClanWarSettings", root, sendClanWarSettings)

function getDataForSync()
	return {status = clanWarState, teams = team1:getData("tag").." vs "..team2:getData("tag"), score = team1Points.." : "..team2Points}
end

function sendMaps()
	local send = {}
	local maps = exports.mapmanager:getMapsCompatibleWithGamemode(Resource.getFromName("race"))
	for i,v in ipairs(maps) do
		send[i] = {["map"] = v:getName(), ["name"] = v:getInfo("name")}
	end
	if #send ~= 0 then
		triggerClientEvent(root, "receiveMaps", root, send, choosenMapsTable)
	end
end
addEvent("requestMaps", true)
addEventHandler("requestMaps", root, sendMaps)

function getChoosenMaps(maps, value)
	if not table.compare(choosenMapsTable, maps) then
		choosenMapsTable = maps
		for i,v in ipairs(maps) do
			if not isTeam3 then
				local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
				if i%2 == 0 then
					i = tc2..i
				else
					i = tc1..i
				end
			end
			outputChatBox(i..". #FFFFFF"..v.name, root, 0, 255, 0, true)
		end
		if value == 0 then
			local byPlayer = newNick(source:getName())
			if #maps ~= 0 then
				outputChatBox("Choosen maps was updated by "..byPlayer, root, 255, 255, 255)
			else
				outputChatBox("Map list was cleaned by "..byPlayer, root, 255, 255, 255)
			end
		else
			outputChatBox("Map list was cleaned by server", root, 255, 255, 255)			
		end
	end
end
addEvent("updateChoosenMaps", true)
addEventHandler("updateChoosenMaps", root, getChoosenMaps)

function addTeamTag(player, cmd, ...)
	if checkACL(player, "Wizu") then
		local words = {...}
		local byPlayer = newNick(player:getName())
		if #words > 1 then
			local tag, full_name = "", ""
			for i,v in ipairs(words) do
				if i == 1 then
					tag = v
					local selected = executeSQLQuery("SELECT full_name FROM wizu_teams WHERE tag=?", tag)
					if #selected ~= 0 then
						return outputChatBox("[ERROR] #FF0000\"#FFFFFF"..tag.."#FF0000\" #FFFFFFalready exists#FF0000.", player, 255, 0, 0, true)
					end
				else
					if i == 2 then
						full_name = v
					else
						full_name = full_name.." "..v
					end
				end
			end
			outputChatBox("("..byPlayer..") #00FF00"..full_name.." #FFFFFFwas added as #00FF00"..tag, root, 255, 255, 255, true)
			executeSQLQuery("INSERT INTO wizu_teams(tag,full_name) VALUES(?,?)", tag, full_name)

			if team1:getData("tag") == tag or team1:getName() == tag then
				team1:setName(full_name)
			elseif team2:getData("tag") == tag or team2:getName() == tag then
				team2:setName(full_name)
			end
			if isTeam3 then
				if team3:getData("tag") == tag or team3:getName() == tag then
					team3:setName(full_name)
				end
			end
		else
			outputChatBox("/addtag HHX HaHaXuy", player)
		end
	end
end
addCommandHandler("addtag", addTeamTag)

function deleteTeamTag(player, cmd, tag)
	if checkACL(player, "Wizu") then
		if tag then
			local byPlayer = newNick(player:getName())
			local selected = executeSQLQuery("SELECT full_name FROM wizu_teams WHERE tag=?", tag)
			if #selected ~= 0 then
				outputChatBox("("..byPlayer..") #FF0000"..selected[1]["full_name"].." #FFFFFFwas deleted as #FF0000"..utf8.upper(tag), root, 255, 255, 255, true)
				executeSQLQuery("DELETE FROM wizu_teams WHERE tag=?", tag)
			else
				outputChatBox("[ERROR] #FFFFFFNo found #FF0000\"#FFFFFF"..tag.."#FF0000\"#FF0000.", player, 255, 0, 0, true)
			end

			if team1:getData("tag") == tag or team1:getName() == tag then
				team1:setName(tag)
			elseif team2:getData("tag") == tag or team2:getName() == tag then
				team2:setName(tag)
			end
			if isTeam3 then
				if team3:getData("tag") == tag or team3:getName() == tag then
					team3:setName(tag)
				end
			end
		else
			outputChatBox("/deltag HHX", player)
		end
	end
end
addCommandHandler("deltag", deleteTeamTag)

function listTeams(player)
	local selected = executeSQLQuery("SELECT tag, full_name FROM wizu_teams")
	if #selected ~= 0 then
		for i,v in ipairs(selected) do
			local tag, full_name = v["tag"], v["full_name"]
			outputChatBox("[Server] #FFFFFF"..tag.."#00FF00 : #FFFFFF"..full_name, root, 0, 255, 0, true)
		end
	else
		outputChatBox("[ERROR] #FFFFFFList empty#FF0000.", root, 255, 0, 0, true)
	end
end
addCommandHandler("teams", listTeams)

function addMapCommand(player, cmd, ...)
	if checkACL(player, "Wizu") then
		local words = {...}
		local byPlayer = newNick(player:getName())
		local maps = exports.mapmanager:getMapsCompatibleWithGamemode(Resource.getFromName("race"))
		if #words > 1 then
			local short, full, found, resource, mapName = "", "", false, ""
			for i,v in ipairs(words) do
				if i == 1 then
					short = v
					local selected = executeSQLQuery("SELECT full FROM maps_commands WHERE short=?", utf8.upper(short))
					if #selected ~= 0 then
						return outputChatBox("[ERROR] #FF0000\"#FFFFFF"..utf8.upper(short).."#FF0000\" #FFFFFFalready exists#FF0000.", player, 255, 0, 0, true)
					end
				else
					if i == 2 then
						full = v
					else
						full = full.." "..v
					end
				end
			end
			for _,res in ipairs(maps) do
				if utf8.upper(full) == utf8.upper(res:getInfo("name")) then
					found = true
					resource = res:getName()
					mapName = res:getInfo("name")
				end
			end
			if found then
				executeSQLQuery("INSERT INTO maps_commands(short,full,resource) VALUES(?,?,?)", utf8.upper(short), mapName, resource)
				outputChatBox("("..byPlayer..") #00FF00"..mapName.." #FFFFFFwas added as #00FF00"..utf8.upper(short), root, 255, 255, 255, true)
			else
				outputChatBox("[ERROR] #FFFFFFNo found map with name #FF0000\"#FFFFFF"..full.."#FF0000\"#FF0000.", player, 255, 0, 0, true)
			end
		else
			outputChatBox("/add S15 [DD] Cross S15", player)
		end
	end
end
addCommandHandler("add", addMapCommand)

function deleteMapCommand(player, cmd, short)
	if checkACL(player, "Wizu") then
		if short then
			local byPlayer = newNick(player:getName())
			local selected = executeSQLQuery("SELECT full FROM maps_commands WHERE short=?", utf8.upper(short))
			if #selected ~= 0 then
				outputChatBox("("..byPlayer..") #FF0000"..selected[1]["full"].." #FFFFFFwas deleted as #FF0000"..utf8.upper(short), root, 255, 255, 255, true)
				executeSQLQuery("DELETE FROM maps_commands WHERE short=?", utf8.upper(short))
			else
				outputChatBox("[ERROR] #FFFFFFNo found #FF0000\"#FFFFFF"..utf8.upper(short).."#FF0000\"#FF0000.", player, 255, 0, 0, true)
			end
		else
			outputChatBox("/delete S15", player)
		end
	end
end
addCommandHandler("delete", deleteMapCommand)

function setMapsByCommand(player, cmd, ...)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		local list = {...}
		local maps = {}
		local map, name
		for _,short in ipairs(list) do
			local selected = executeSQLQuery("SELECT full FROM maps_commands WHERE short=?", utf8.upper(short))
			if #selected ~= 0 then
				name = selected[1]["full"]
				local resource = executeSQLQuery("SELECT resource FROM maps_commands WHERE short=?", utf8.upper(short))
				if #resource ~= 0 then
					map = resource[1]["resource"]
					if Resource.getFromName(map) then
						table.insert(maps, {["map"] = map, ["name"] = name})
					end
				else
					return outputChatBox("[ERROR] #FFFFFFNo found #FF0000\"#FFFFFF"..utf8.upper(resource).."#FF0000\"#FF0000.", player, 255, 0, 0, true)
				end
			else
				return outputChatBox("[ERROR] #FFFFFFNo found #FF0000\"#FFFFFF"..utf8.upper(short).."#FF0000\"#FF0000.", player, 255, 0, 0, true)
			end
		end
		local count = #maps
		if count > 0 then
			if count == 2 or count == 4 then
				triggerEvent("updateChoosenMaps", player, maps, 0)
			else
				if isTeam3 then
					if count ~= 4 then
						outputChatBox("[ERROR] #FFFFFFMaps count should be #FF00004#FFFFFF.", player, 255, 0, 0, true)
					end
				else
					outputChatBox("[ERROR] #FFFFFFMaps count should be #FF00002 #FFFFFFor #FF00004#FFFFFF.", player, 255, 0, 0, true)
				end
			end
		else
			triggerEvent("updateChoosenMaps", player, {}, 0)
		end
	end
end
addCommandHandler("set", setMapsByCommand)

function listMaps(player)
	local selected = executeSQLQuery("SELECT short, full FROM maps_commands")
	if #selected ~= 0 then
		for i,v in ipairs(selected) do
			local short, full = v["short"], v["full"]
			outputChatBox("[Server] #FFFFFF"..short.."#00FF00 : #FFFFFF"..full, player, 0, 255, 0, true)
		end
	else
		outputChatBox("[ERROR] #FFFFFFList empty#FF0000.", player, 255, 0, 0, true)
	end
end
addCommandHandler("wizu_list", listMaps)

function setClanWarMap(timer)
	if Timer.isValid(setClanWarMapTimer) then setClanWarMapTimer:destroy() end
	local mapsCount = #choosenMapsTable
	if roundsLeft > 0 then
		if mapsCount == 0 then
			setClanWarMapTimer = Timer(
				function()
					if clanWarState == "Free" then return end
					exports.mapmanager:changeGamemodeMap(exports.mapmanager:getRunningGamemodeMap())
				end, timer, 1)
			return
		else
			local perMap = rounds / mapsCount
			local summ = team1Points + team2Points
			if isTeam3 then
				summ = summ + team3Points
			end
			for i = 1, mapsCount do
				if summ < i * perMap then
					setClanWarMapTimer = Timer(
						function()
							if clanWarState == "Free" then return end
							exports.mapmanager:changeGamemodeMap(Resource.getFromName(choosenMapsTable[i].map))
						end, timer, 1)
					return
				end
			end
		end
	else
		if mapsCount == 2 then
			local summ, i = team1Points + team2Points, 1
			if isTeam3 then
				summ = summ + team3Points
			end
			if string.match(summ/2, "^%d+.5$") then
				i = 2
			end
			setClanWarMapTimer = Timer(
				function()
					if clanWarState == "Free" then return end
					exports.mapmanager:changeGamemodeMap(Resource.getFromName(choosenMapsTable[i].map))
				end, timer, 1)
			return
		elseif mapsCount == 4 then
			local summ, i = team1Points + team2Points, 1
			if isTeam3 then
				summ = summ + team3Points
			end
			if string.match(summ/4, "^%d+.25$") then
				i = 2
			elseif string.match(summ/4, "^%d+.5$") then
				i = 3
			elseif string.match(summ/4, "^%d+.75$") then
				i = 4
			end
			setClanWarMapTimer = Timer(
				function()
					if clanWarState == "Free" then return end
					exports.mapmanager:changeGamemodeMap(Resource.getFromName(choosenMapsTable[i].map))
				end, timer, 1)
			return
		end
	end
	sendClanWarSettings()
	setClanWarMapTimer = Timer(
		function()
			if clanWarState == "Free" then return end
			exports.mapmanager:changeGamemodeMap(exports.mapmanager:getRunningGamemodeMap())
		end, timer, 1)
	return
end

addEvent("onMapStarting")
addEventHandler("onMapStarting", root,
function(mapInfo)
	currentMapName = mapInfo.name
	currentMapMode = mapInfo.modename or "None"
	if currentMapName:find("%[RS%]") and clanWarState == "Live" then
		changeStatus(_, "Free")
	end
end)

addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
function(new, old)
	currentMapState = new
	if clanWarState == "Live" then
		if new == "Running" and spectatorsKill then
			for _,player in pairs(Element.getAllByType("player")) do
				if player:getTeam() == teamS or string.find(newNick(player:getName()), "(S)", 1, true) then
					local vehicle = player:getOccupiedVehicle()
					if isElement(vehicle) then
						toggleAllControls(player, false, true, false)
						vehicle:setOverrideLights(1)
						vehicle:setAlpha(0)
						vehicle:setCollisionsEnabled(false)
						player:setAlpha(0)
						Timer(
							function()
								if isElement(player) then
									triggerEvent("onClientRequestSpectate", player, false)
									triggerEvent("onRequestKillPlayer", player)
								end
								if isElement(vehicle) then
									vehicle:setPosition(0, 0, 0, false)
								end
							end
						, 50, 1)
						Timer(vehicle.blow, 100, 1, vehicle, false)
					end
				end
			end
		end
		if new == "Running" then
			isSomeoneWon = false
			winnerTeam = nil
		end
		if new == "TimesUp" then
			setClanWarMap(50)
		end
		if new == "PostFinish" then
			isStoped = false
			setGameSpeed(1)
			if Timer.isValid(stopTimer) then stopTimer:destroy() end
			triggerClientEvent(root, "showStopTimer", root, false)
		end
	end
end)

function setWinner(team)
	checkTeams()
	if not isElement(team) or clanWarState == "Free" or isSomeoneWon then return end
	local teamName, teamColor, text, number = team:getName(), RGBToHex(team:getColor()), ""
	setPointsToTeam(team, "add")
	isSomeoneWon = true
	if team == team1 then
		winnerTeam = 1
	elseif team == team2 then
		winnerTeam = 2
	elseif team == team3 then
		winnerTeam = 3
	end
	sendClanWarSettings()
	if isTeam3 then
		if roundsLeft > 1 then
			text = teamColor..teamName.."#FFFFFF won this round! "..team1Points.." : "..team2Points.." : "..team3Points
		else
			number = 4
			if string.match(math.abs(roundsLeft/number), "^%d+$") then
				if team1Points > team2Points and team1Points > team3Points then
					local cTeam = getEditedTeam("1")
					local teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "Match ended: "..teamColor..teamName.."#FFFFFF won this match! "..team1Points.." : "..team2Points.." : "..team3Points
					if team1Points > team2Points + 2 and team1Points > team3Points + 2 then
						getChoosenMaps({}, 1)
					end
					changeStatus(_, "Free")
				elseif team2Points > team1Points and team2Points > team3Points then
					local cTeam = getEditedTeam("2")
					local teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "Match ended: "..teamColor..teamName.."#FFFFFF won this match! "..team1Points.." : "..team2Points.." : "..team3Points
					if team2Points > team1Points + 2 and team2Points > team3Points + 2 then
						getChoosenMaps({}, 1)
					end
					changeStatus(_, "Free")
				elseif team3Points > team1Points and team3Points > team2Points then
					local cTeam = getEditedTeam("3")
					local teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "Match ended: "..teamColor..teamName.."#FFFFFF won this match! "..team1Points.." : "..team2Points.." : "..team3Points
					if team3Points > team1Points + 2 and team3Points > team2Points + 2 then
						getChoosenMaps({}, 1)
					end
					changeStatus(_, "Free")
				else
					text = teamColor..teamName.."#FFFFFF won this round! "..team1Points.." : "..team2Points.." : "..team3Points
				end
			else
				text = teamColor..teamName.."#FFFFFF won this round! "..team1Points.." : "..team2Points.." : "..team3Points
			end
		end
	else
		local tc1, tc2 = RGBToHex(team1:getColor()), RGBToHex(team2:getColor())
		if roundsLeft > 1 then
			if team == team1 then
				text = teamColor..teamName.."#FFFFFF won this round! "..tc1..team1Points.." #FFFFFF: "..tc2..team2Points
			elseif team == team2 then
				text = teamColor..teamName.."#FFFFFF won this round! "..tc2..team2Points.." #FFFFFF: "..tc1..team1Points
			end
		else
			if scriptType == "ClanWar" then
				number = 4
			elseif scriptType == "PvP" then
				number = 2
			end
			if string.match(math.abs(roundsLeft/number), "^%d+$") then
				if team1Points > team2Points then
					local cTeam = getEditedTeam("1")
					local teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "Match ended: "..teamColor..teamName.."#FFFFFF won this match! "
														..tc1..team1Points.." #FFFFFF: "..tc2..team2Points.." "
					if team1Points > team2Points + 2 then
						getChoosenMaps({}, 1)
					end
					changeStatus(_, "Free")
				elseif team1Points < team2Points then
					local cTeam = getEditedTeam("2")
					local teamName, teamColor = cTeam:getName(), RGBToHex(cTeam:getColor())
					text = "Match ended: "..teamColor..teamName.."#FFFFFF won this match! "
														..tc1..team1Points.." #FFFFFF: "..tc2..team2Points.." "
					if team1Points + 2 < team2Points then
						getChoosenMaps({}, 1)
					end
					changeStatus(_, "Free")
				else
					local tn1, tn2 = team1:getName(), team2:getName()
					text = "#FFA500Match ended: "..tc1..tn1.."#FFFFFF ("..team1Points.." : "..team2Points..") "..tc2..tn2
					changeStatus(_, "Free")
				end
			else
				if team == team1 then
					text = teamColor..teamName.."#FFFFFF won this round! "..tc1..team1Points.." #FFFFFF: "..tc2..team2Points
				elseif team == team2 then
					text = teamColor..teamName.."#FFFFFF won this round! "..tc2..team2Points.." #FFFFFF: "..tc1..team1Points
				end
			end
		end
	end
	outputServerLog("CLANWAR: "..newNick(text))
	outputChatBox(text, root, 255, 255, 255, true)
	exports["ae-sync"]:sendDiscordMessage(text)
	if isRedoPoll then
		stopRedoPoll()
	end
	setClanWarMap(2000)
end

function teamToStringPlayers(team)
	local myString = ""
	local myPlayers = getPlayersInTeam(team)
	for i = 1, #myPlayers do
		myString = myString..(getPlayerName(myPlayers[i]):gsub("#%x%x%x%x%x%x", ""))
		if i ~= #myPlayers then
			myString = myString.."\n"
		end
	end
	return myString
end

function checkPoints()
	if clanWarState == "Live" and autoPoints and currentMapMode == "Destruction derby" and not isSomeoneWon then
		checkTeams()
		if isTeam3 then
			if isElement(source:getTeam()) and source:getTeam() == team1 then
				if getAlivePlayersInTeamCount(team1) > 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team1)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) > 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team2)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) > 0 then
					setWinner(team3)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team1)
				end
			elseif isElement(source:getTeam()) and source:getTeam() == team2 then
				if getAlivePlayersInTeamCount(team1) > 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team1)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) > 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team2)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) > 0 then
					setWinner(team3)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team2)
				end
			elseif isElement(source:getTeam()) and source:getTeam() == team3 then
				if getAlivePlayersInTeamCount(team1) > 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team1)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) > 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team2)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) > 0 then
					setWinner(team3)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team3) == 0 then
					setWinner(team3)
				end
			end
		else
			if isElement(source:getTeam()) and source:getTeam() == team1 then
				if getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) > 0 then
					setWinner(team2)
				elseif getAlivePlayersInTeamCount(team1) > 0 and getAlivePlayersInTeamCount(team2) == 0 then
					setWinner(team1)
				elseif getAlivePlayersInTeamCount(team1) == 0 and getAlivePlayersInTeamCount(team2) == 0 then
					setWinner(team1)
				end
			elseif isElement(source:getTeam()) and source:getTeam() == team2 then
				if getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team1) > 0 then
					setWinner(team1)
				elseif getAlivePlayersInTeamCount(team2) > 0 and getAlivePlayersInTeamCount(team1) == 0 then
					setWinner(team2)
				elseif getAlivePlayersInTeamCount(team2) == 0 and getAlivePlayersInTeamCount(team1) == 0 then
					setWinner(team2)
				end
			end
		end
	end
end

addEventHandler("onPlayerWasted", root, checkPoints, true, "low")
addEventHandler("onPlayerQuit", root, checkPoints, true, "low")

addEvent("onGamemodeMapStart")
addEventHandler("onGamemodeMapStart", root,
function()
	team1Members = {}
	team2Members = {}
	if Timer.isValid(setClanWarMapTimer) then setClanWarMapTimer:destroy() end
	if isRedoPoll then stopRedoPoll() end
	isStoped = false
	setGameSpeed(1)
	if Timer.isValid(stopTimer) then stopTimer:destroy() end
	triggerClientEvent(root, "showStopTimer", root, false)

	for i,v in ipairs(Element.getAllByType("player")) do
		if v:getTeam() == team1 then
			table.insert(team1Members, v:getSerial())
		elseif v:getTeam() == team2 then
			table.insert(team2Members, v:getSerial())
		end
		v:removeData("toptimes")
	end
end, true, "low")

function isFromAllowList(command)
	local list = {"sban", "givea", "givesm", "add", "delete", "addtag", "deltag", "teams", "kick", "mute", "unmute", "mmute", "repair", "freeze", "ban", "stn", "stc", "ap", "dp", "sp", "rp", "specchat", "speckill", "changetype", "autopoints", "team3", "training", "res", "fix", "god", "sl", "ll", "dl", "push", "boost"}
	for i,v in ipairs(list) do
		if command == v then
			return true
		end
	end
	return false
end

addEventHandler("onPlayerChat", root,
function(message, messageType)
	if source:isMuted() then return end
	if source:getData("isMuted") then return end
	if clanWarState == "Training" then return end
	if messageType == 0 then
		if not spectatorsChat and source:getTeam() == teamS then
			cancelEvent()
			outputChatBox("say: Spectators chat is muted", source, 255, 165, 0)
			return
		end
		if message:lower() == "f" or message:lower() == "fre" or message:lower() == "free" then
			if changeStatus(source, "Free") then
				cancelEvent()
			end
		elseif message:lower() == "l" or message:lower() == "liv" or message:lower() == "live" then
			if changeStatus(source, "Live") then
				cancelEvent()
			end
		elseif message:lower() == "rl" or message:lower() == "rlive" or message:lower() == "redo live" then
			if checkACL(source, "Moderator") or checkACL(source, "SuperModerator") or checkACL(source, "Admin") then
				if clanWarState == "Free" then
					changeStatus(source, "Live")
					cancelEvent()
				end
				setClanWarMap(50)
				if scriptType == "ClanWar" and roundsLeft == 20 then
					outputChatBox("#00FF00Clan war #FFFFFFstarted! gl hf", root, 255, 255, 255, true)
					exports["ae-sync"]:sendDiscordMessage("#00FF00Clan war #FFFFFFstarted! gl hf")
				elseif scriptType == "PvP" and roundsLeft == 10 then
					outputChatBox("#FF0000PvP #FFFFFFstarted! gl hf", root, 255, 255, 255, true)
				end
			end
		end
		if message:match("^!(.+)$") then
			local message_table, list = split(message, " ")
			local cmd = message_table[1]:gsub("!", "")
			if isFromAllowList(cmd) then
				setTimer(executeCommandHandler, 50, 1, cmd, source, message:gsub("!"..cmd.." ", ""))
			end
		end
		if message:match("^!set$") or message:match("^!set (.+) (.+)$") or message:match("^!set (.+) (.+) (.+) (.+)$") then
			if message ~= "!set" then
				setTimer(executeCommandHandler, 50, 1, "set", source, message:gsub("!set ", ""))
			end
		elseif message:match("^!set (.+)$") then
			message = message:gsub("!set ", "")
			local count = #split(message, " ")
			if isTeam3 then
				if count ~= 4 then
					setTimer(outputChatBox, 50, 1, "[ERROR] #FFFFFFMaps count should be #FF00004#FFFFFF.", source, 255, 0, 0, true)
				end
			else
				setTimer(outputChatBox, 50, 1, "[ERROR] #FFFFFFMaps count should be #FF00002 #FFFFFFor #FF00004#FFFFFF.", source, 255, 0, 0, true)
			end
		elseif message == "!reset" then
			setTimer(executeCommandHandler, 50, 1, "set", source)
		elseif message == "!list" then
			setTimer(executeCommandHandler, 50, 1, "wizu_list", source)
		end
		if not isTeam3 then
			if clanWarState == "Live" and currentMapState == "Running" then
				if not isRedoPoll then
					if message:lower() == "r" or message:lower() == "r?" or message:lower() == "redo" or message:lower() == "redo?" then
						if isElement(source:getTeam()) then
							if source:getTeam() == team1 then
								for i,v in ipairs(team2Members) do
									if source:getSerial() == v then
										cancelEvent()
										return outputChatBox("[Server] #FF0000Get out bitch", source, 68, 68, 68, true)
									end
								end
								startRedoPoll(source)
							elseif source:getTeam() == team2 then
								for i,v in ipairs(team1Members) do
									if source:getSerial() == v then
										cancelEvent()
										return outputChatBox("[Server] #FF0000Get out bitch", source, 68, 68, 68, true)
									end
								end
								startRedoPoll(source)
							end
						end
					end
				end
			end
		end
		if currentMapState == "Running" and not Timer.isValid(stopTimer) and source:getTeam() ~= teamS then
			if message:lower() == "s" or message:lower() == "stop" then
				stopClanWar(true)
			end
		end

		if isStoped and not Timer.isValid(stopTimer) and source:getTeam() ~= teamS then
			if message:lower() == "g" or message:lower() == "go" then
				stopClanWar(false)
			end
		end

		if isRedoPoll then
			local count1, count2
			if isElement(team1) then count1 = getAlivePlayersInTeamCount(team1) end
			if isElement(team2) then count2 = getAlivePlayersInTeamCount(team2) end

			if source:getTeam() == team1 or source:getTeam() == team2 then
				if message:lower() == "n" or message:lower() == "no" then
					stopRedoPoll()
				end
			end
			if pollTeam == team1 then
				if source:getTeam() == team2 then
					if count1 == 1 and count2 == 1 then
						local vehicle = getAlivePlayersInTeam(team2)[1]:getOccupiedVehicle()
						if isElement(vehicle) then
							if message:lower() == "g" or message:lower() == "go" or message:lower() == "r" then
								for i,v in ipairs(team2Members) do
									if v == source:getSerial() then
										if vehicle:isInWater() and not isWater then
											cancelEvent()
											if source == getAlivePlayersInTeam(team2)[1] then
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while"
																		.."#FF0000 in water.", source, 255, 255, 255, true)
											else
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while \""
																		..getAlivePlayersInTeam(team2)[1]:getName()
																		.."\"#FF0000 in water.", source, 255, 255, 255, true)
											end
										end
										if not vehicle:isOnGround() and not isAir then
											cancelEvent()
											if source == getAlivePlayersInTeam(team2)[1] then
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while"
																		.."#FF0000 in air.", source, 255, 255, 255, true)
											else
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while \""
																		..getAlivePlayersInTeam(team2)[1]:getName()
																		.."\"#FF0000 in air.", source, 255, 255, 255, true)
											end
										end
										stopRedoPoll()
										setClanWarMap(1000)
									end
								end
							end
						end
					else
						if message:lower() == "g" or message:lower() == "go" or message:lower() == "r" then
							for i,v in ipairs(team2Members) do
								if v == source:getSerial() then
									stopRedoPoll()
									setClanWarMap(1000)
								end
							end
						end
					end
				end
			elseif pollTeam == team2 then
				if source:getTeam() == team1 then
					if count1 == 1 and count2 == 1 then
						local vehicle = getAlivePlayersInTeam(team1)[1]:getOccupiedVehicle()
						if isElement(vehicle) then
							if message:lower() == "g" or message:lower() == "go" or message:lower() == "r" then
								for i,v in ipairs(team1Members) do
									if v == source:getSerial() then
										if vehicle:isInWater() and not isWater then
											cancelEvent()
											if source == getAlivePlayersInTeam(team1)[1] then
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while"
																		.."#FF0000 in water.", source, 255, 255, 255, true)
											else
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while \""
																		..getAlivePlayersInTeam(team1)[1]:getName()
																		.."\"#FF0000 in water.", source, 255, 255, 255, true)
											end
										end
										if not vehicle:isOnGround() and not isAir then
											cancelEvent()
											if source == getAlivePlayersInTeam(team1)[1] then
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while"
																	.."#FF0000 in air.", source, 255, 255, 255, true)
											else
												return outputChatBox("#444444[Server] #FF0000You can't accept redo while \""
																		..getAlivePlayersInTeam(team1)[1]:getName()
																		.."\"#FF0000 in air.", source, 255, 255, 255, true)
											end
										end
										stopRedoPoll()
										setClanWarMap(1000)
									end
								end
							end
						end
					else
						if message:lower() == "g" or message:lower() == "go" or message:lower() == "r" then
							for i,v in ipairs(team1Members) do
								if v == source:getSerial() then
									stopRedoPoll()
									setClanWarMap(1000)
								end
							end
						end
					end
				end
			end
		end
	end
end, true, "high")

function stopClanWar(value)
	if Timer.isValid(stopTimer) then stopTimer:destroy() end
	if value then
		if not isStoped then
			triggerClientEvent(root, "showStopTimer", root, true, true, 3)
			stopTimer = 
			Timer(
				function()
					if Timer.isValid(stopTimer) then
						local _, remain = stopTimer:getDetails()
						triggerClientEvent(root, "showStopTimer", root, true, true, remain - 1)
						if remain == 1 then
							setGameSpeed(0)
						end
					end
				end
			, 1000, 3)
			isStoped = true
		end
	else
		triggerClientEvent(root, "showStopTimer", root, true, false, 4)
		stopTimer = 
		Timer(
			function()
				if Timer.isValid(stopTimer) then
					local _, remain = stopTimer:getDetails()
					triggerClientEvent(root, "showStopTimer", root, true, false, remain - 1)
					if remain == 2 then
						setGameSpeed(1)
					elseif remain == 1 then
						triggerClientEvent(root, "showStopTimer", root, false)							
						isStoped = false
					end
				end
			end
		, 1000, 4)
	end
end

function startRedoPoll(player)
	if Timer.isValid(setClanWarMapTimer) then return end
	if Timer.isValid(redoPollTimer) then redoPollTimer:destroy() end
	checkTeams()
	local nick = newNick(player:getName())
	local team = player:getTeam()
	if isElement(team) then
		if team == team1 or team == team2 then
			isRedoPoll = true
			pollNick = nick
			pollTeam = team
			triggerClientEvent(root, "receivePoll", root, true, nick, team)
		end
	end
	redoPollTimer = Timer(stopRedoPoll, 10000, 1)
	sendClanWarSettings()
end

function stopRedoPoll()
	checkTeams()	
	if Timer.isValid(redoPollTimer) then
		local left = redoPollTimer:getDetails()
		if left > 0 then
			redoPollTimer:destroy()
		else
			if pollTeam == team1 then
				local tn, tc = team2:getName(), RGBToHex(team2:getColor())
				outputChatBox("Redo automatically #FF0000denied! #FFFFFF\""..tc..tn.."#FFFFFF\" didn't answer"
																					, root, 255, 255, 255, true)
			elseif pollTeam == team2 then
				local tn, tc = team1:getName(), RGBToHex(team1:getColor())
				outputChatBox("Redo automatically #FF0000denied! #FFFFFF\""..tc..tn.."#FFFFFF\" didn't answer"
																					, root, 255, 255, 255, true)
			end
		end
	end
	
	isRedoPoll = false
	pollNick = nil
	pollTeam = nil
	triggerClientEvent(root, "receivePoll", root, false)
end

addEventHandler("onPlayerJoin", root,
function()
	if clanWarState == "Training" then
		outputChatBox("Use /res to respawn. /sl to save location /ll to load saved location.", source, 0, 255, 0)
		teleports[source] = {}
	end
	if isRedoPoll then
		triggerClientEvent(root, "receivePoll", root, true, pollNick, pollTeam)		
	end
end)

function changeStatus(source, state)
	if isElement(source) then
		if clanWarState ~= state then
			local byPlayer, message = newNick(source:getName()), ""
			message = "("..byPlayer.."#FFFFFF) "..scriptType.." state was changed to "..state
			if state == "Live" then
				message = message:gsub("Live", "#00FF00Live")
				if currentMapName:find("%[RS%]") then
					return outputChatBox("You can't do that in RS maps!", source, 255, 0, 0)
				end
			elseif state == "Free" then
				if isRedoPoll then stopRedoPoll() end
				message = message:gsub("Free", "#FF0000Free")
				
				isStoped = false
				setGameSpeed(1)
				if Timer.isValid(stopTimer) then stopTimer:destroy() end
				triggerClientEvent(root, "showStopTimer", root, false)
			end
			clanWarState = state
			sendClanWarSettings()
			exports["ae-sync"]:sendDiscordMessage(message)
			outputChatBox(message, root, 255, 255, 255, true)
			return true
		end
	else
		if clanWarState ~= state then
			local message = ""
			clanWarState = state
			message = scriptType.." state was changed to "..state
			if state == "Live" then
				message = message:gsub("Live", "#00FF00Live")
				if currentMapName:find("%[RS%]") then
					return
				end
			elseif state == "Free" then
				if isRedoPoll then stopRedoPoll() end
				message = message:gsub("Free", "#FF0000Free")
			end
			exports["ae-sync"]:sendDiscordMessage(message)
			outputChatBox(message, root, 255, 255, 255, true)
			sendClanWarSettings()
			return true
		end
		return true
	end
	return false
end

function initPlayers()
	if isElement(source) and source:getType() == "player" then
		if checkACL(source, "Moderator") or checkACL(source, "SuperModerator") or checkACL(source, "Admin") then
			bindKey(source, get("cwPanelKey") or "F4", "down", "OpenSettings")
		end
		source:setData("isSettingWindowOpened", false)
	else
		for _,player in pairs(Element.getAllByType("player")) do
			if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
				bindKey(player, get("cwPanelKey") or "F4", "down", "OpenSettings")
			end
			player:setData("isSettingWindowOpened", false)
		end
	end
end
addEventHandler("onResourceStart", getThisResource():getRootElement(), 
function()
	setGameSpeed(1)
	team1Members = {}
	team2Members = {}
	for i,v in ipairs(Element.getAllByType("player")) do
		if v:getTeam() == team1 then
			table.insert(team1Members, v:getSerial())
		elseif v:getTeam() == team2 then
			table.insert(team2Members, v:getSerial())
		end
	end
end)
addEventHandler("onResourceStart", getThisResource():getRootElement(), initPlayers)
addEventHandler("onResourceStop", getThisResource():getRootElement(),
function()
	for _,player in pairs(Element.getAllByType("player")) do
		unbindKey(player, get("cwPanelKey") or "F4", "down", "OpenSettings")		
		player:setData("isSettingWindowOpened", false)
	end
end)
addEventHandler("onPlayerLogin", root, initPlayers)

addEventHandler("onPlayerLogin", root,
function()
	if checkACL(source, "Moderator") or checkACL(source, "SuperModerator") or checkACL(source, "Admin") then
		outputChatBox("[Server] #FFFFFFUse \"#FF0000"..(get("cwPanelKey") or "F5").."#FFFFFF\" to change maps presets.", source, 68, 68, 68, true)
		outputChatBox("[Server] #FFFFFFUse \"#FF0000F6#FFFFFF\" to switch to our other servers.", source, 68, 68, 68, true)
		outputChatBox("[Server] #FFFFFFUse \"#FF0000F9#FFFFFF\" to see all the useful commands.", source, 68, 68, 68, true)
		outputChatBox("[Server] #FFFFFFUse \"#FF0000/cradar#FFFFFF\" to open the radar settings menu.", source, 68, 68, 68, true)
	end
end)

addEventHandler("onPlayerLogout", root,
function()
	unbindKey(source, get("cwPanelKey") or "F4", "down", "OpenSettings")
	if source:getData("isSettingWindowOpened") then
		toggleAllControls(source, true, true, true)
		source:triggerEvent("openSettingsWindow", source)
		source:setData("isSettingWindowOpened", false)
	end
end)

function openWindow(source)
	if checkACL(source, "Moderator") or checkACL(source, "SuperModerator") or checkACL(source, "Admin") then
		for _,player in pairs(Element.getAllByType("player")) do
			if player:getData("isSettingWindowOpened") and player ~= source then
				return outputChatBox(newNick(player:getName()).." already edit clan war settings", source, 255, 0, 0)
			end
		end
		source:triggerEvent("openSettingsWindow", source)
		source:setData("isSettingWindowOpened", not source:getData("isSettingWindowOpened"))
		sendClanWarSettings()
		if source:getData("isSettingWindowOpened") then
			toggleAllControls(source, false, false, false)
		else
			toggleAllControls(source, true, true, true)
		end
	end
end
addCommandHandler("OpenSettings", openWindow)

addEvent("updateTeamSettings", true)
addEventHandler("updateTeamSettings", root,
function(team, name, color, points)
	local cTeam, cPoints, full_name
	local points = tonumber(points)
	if team == 1 then
		cTeam = team1
		cPoints = team1Points
	elseif team == 2 then
		cTeam = team2
		cPoints = team2Points
	elseif team == 3 then
		cTeam = team3
		cPoints = team3Points
	end
	if isElement(cTeam) then
		local cName, cColor = cTeam:getName(), RGBToHex(cTeam:getColor())
		local byPlayer = newNick(client:getName())
		local selected = executeSQLQuery("SELECT full_name FROM wizu_teams WHERE tag=?", name)
		if #selected ~= 0 then
			full_name = selected[1]["full_name"]
		else
			full_name = name
		end
		if cName ~= full_name and cColor ~= color and cPoints ~= points then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" was changed to \""..color..full_name..
			"#FFFFFF\" ("..cPoints.." to "..points..") by "..byPlayer, root, 255, 255, 255, true)
		elseif cName ~= full_name and cColor ~= color then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" was changed to \""..color..full_name.."#FFFFFF\" by "
			..byPlayer, root, 255, 255, 255, true)
		elseif cName ~= full_name and cPoints ~= points then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" was changed to \""..color..full_name.."#FFFFFF\" ("
			..cPoints.." to "..points..") by "..byPlayer, root, 255, 255, 255, true)
		elseif cColor ~= color and cPoints ~= points then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" was changed to \""..color..color:gsub("#", "").."#FFFFFF\" ("
			..cPoints.." to "..points..") by "..byPlayer, root, 255, 255, 255, true)
		elseif cName ~= full_name then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" was changed to \""..color..full_name.."#FFFFFF\" by "
			..byPlayer, root, 255, 255, 255, true)
		elseif cColor ~= color then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" color was changed to \""..color..color:gsub("#", "").."#FFFFFF\" by "
			..byPlayer, root, 255, 255, 255, true)
		elseif cPoints ~= points then
			outputChatBox("\""..cColor..cName.."#FFFFFF\" points was updated ("..cPoints.." to "..points..") by "
			..byPlayer, root, 255, 255, 255, true)
		end

		cTeam:setName(full_name)
		cTeam:setData("tag", name)

		cTeam:setColor(getColorFromString(color))
		if team == 1 then
			team1Points = points
		elseif team == 2 then
			team2Points = points
		elseif team == 3 then
			team3Points = points
		end
	end
	sendClanWarSettings()
end)

Timer(assignToTeam, 500, 0)

addEventHandler("onVehicleEnter", root, function(player) carTeamColor(player) end)

addEvent("onPlayerPickUpRacePickup")
addEventHandler("onPlayerPickUpRacePickup", root,
function(_, type)
	if type == "vehiclechange" then
		carTeamColor(source)
	end
end)

addCommandHandler("training",
function(player)
	if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
		local byPlayer = newNick(player:getName())
		if clanWarState == "Live" then
			return outputChatBox("[Training] #FFFFFFFirstly set "..scriptType.." state to #FF0000Free", player, 68, 68, 68, true)
		elseif clanWarState == "Free" then
			clanWarState = "Training"
			outputChatBox("[Server] #FFFFFFTraning mode was turned \"#00FF00ON#FFFFFF\" by "..byPlayer, root, 68, 68, 68, true)
			outputChatBox("[Training] #FFFFFFCommands: /RES /FIX /GOD /SL /LL /DL /PUSH /BOOST", root, 68, 68, 68, true)
			for i,v in ipairs(Element.getAllByType("player")) do
				if v:getOccupiedVehicle() then (v:getOccupiedVehicle()):setDamageProof(false) end
				teleports[v] = {}
			end
			outputServerLog("CLANWAR: Training mode was turned ON by "..byPlayer)
		elseif clanWarState == "Training" then
			clanWarState = "Free"
			outputChatBox("[Server] #FFFFFFTraning mode was turned \"#FF0000OFF#FFFFFF\" by "..byPlayer, root, 68, 68, 68, true)
			for i,v in ipairs(Element.getAllByType("player")) do
				if v:getOccupiedVehicle() then (v:getOccupiedVehicle()):setDamageProof(false) end
			end
			for k,v in pairs(teleports) do
				teleports[k] = nil
			end
			outputServerLog("CLANWAR: Training mode was turned OFF by "..byPlayer)
		end
		sendClanWarSettings()
	end	
end)

addCommandHandler("res",
function(player)
	if clanWarState ~= "Training" then return end
	if #Element.getAllByType("spawnpoint") == 0 then
		return outputChatBox("[Training] #FF0000Something wrong with map.", root, 68, 68, 68, true)
	end

	local number = math.random(1, #Element.getAllByType("spawnpoint"))
	local spawn = Element.getAllByType("spawnpoint")[number]

	local rotation = spawn:getData("rotation")
	local rotX, rotY, rotZ = spawn:getData("rotX"), spawn:getData("rotY"), spawn:getData("rotZ")
	local posX, posY, posZ = spawn:getData("posX"), spawn:getData("posY"), spawn:getData("posZ")
	local vehicleID = spawn:getData("vehicle")

	if vehicleID then
		local vehicle = exports.race:getPlayerVehicle(player)
		if isElement(vehicle) then

			player:triggerEvent('onClientCall_race', player, "Spectate.stop", 'manual')
			triggerEvent('onClientRequestSpectate', player, false)
			player:triggerEvent('onClientCall_race', player, "Spectate.stop", 'manual')

			if vehicle:respawn() then
			else
				vehicle:setPosition(posX, posY, posZ)
				vehicle:setRotation(rotX or 0, rotY or 0, rotZ or rotation or 0)
			end

			player:setData("race.spectating", false)
			player:setData("status1", "alive")
			player:setData("status2", nil)
			player:setData("state", "alive")

			player:setData("race.finished", false)
			vehicle:setData("race.collideworld", 1)
			vehicle:setData("race.collideothers", 0)
			player:setData("race.alpha", 255)
			vehicle:setData("race.alpha", 255)

			vehicle:setModel(tonumber(vehicleID))
			vehicle:setHealth(1000)
			player:spawn(posX, posY, posZ)
			player:warpIntoVehicle(vehicle)
			setCameraTarget(player, player)

			vehicle:setFrozen(true)
			toggleAllControls(player, true)
			vehicle:setLandingGearDown(true)

			outputChatBox("[Training] #FFFFFFYou #00FF00respawned#FFFFFF.", player, 68, 68, 68, true)
			if currentMapMode == "Sprint" then
				player:setData("toptimes", "off")
			end

			Timer(
				function()
					if isElement(vehicle) then
						vehicle:setFrozen(false)
					end
				end
			, 500, 1)
		end
	end
end)

addCommandHandler("fix",
function(player)
	if clanWarState ~= "Training" then return end
	local vehicle = player:getOccupiedVehicle()
	if isElement(vehicle) then
		vehicle:fix()
		outputChatBox("[Training] #FFFFFFVehicle #00FF00fixed#FFFFFF.", player, 68, 68, 68, true)
		if currentMapMode == "Sprint" then
			player:setData("toptimes", "off")
		end
	end
end)

addCommandHandler("god",
function(player)
	if clanWarState ~= "Training" then return end
	local vehicle = player:getOccupiedVehicle()
	if isElement(vehicle) then
		vehicle:setDamageProof(not vehicle:isDamageProof())
		if vehicle:isDamageProof() then
			vehicle:fix()
			outputChatBox("[Training] #FFFFFFGodmode turned \"#00FF00ON#FFFFFF\".", player, 68, 68, 68, true)
			if currentMapMode == "Sprint" then
				player:setData("toptimes", "off")
			end
		else
			outputChatBox("[Training] #FFFFFFGodmode turned \"#FF0000OFF#FFFFFF\".", player, 68, 68, 68, true)
		end
	end
end)

addEventHandler("onPlayerQuit", root,
function()
	teleports[source] = nil
	if #Element.getAllByType("player") - 1 == 0 then
		clanWarState = "Free"
		team1Members = {}
		team2Members = {}
		scriptType = "ClanWar"
		choosenMapsTable = {}
	end
end)

function _setVelocity(...)
	if setElementAngularVelocity then
		return setElementAngularVelocity(...)
	-- else
	-- 	return setVehicleTurnVelocity(...)
	end
end
 
function _getVelocity(...)
	if getElementAngularVelocity then
		return getElementAngularVelocity(...)
	-- else
	-- 	return getVehicleTurnVelocity(...)
	end
end

addCommandHandler("sl",
function(player, cmd)
	if clanWarState ~= "Training" then return end
	local vehicle = player:getOccupiedVehicle()
	if isElement(vehicle) then
		local x, y, z = vehicle:getPosition()
		local rx, ry, rz = vehicle:getRotation()
		local vx, vy, vz = getElementVelocity(vehicle)
		local avx, avy, avz = _getVelocity(vehicle)

		if type(teleports[player]) ~= "table" then
			teleports[player] = {}
		end

		if teleports[player] and Timer.isValid(teleports[player].timer) then
			return outputChatBox("[Training] #FF0000Cant save while respawning#FFFFFF.", player, 68, 68, 68, true)
		end

		if teleports[player][3] == nil then
			if teleports[player][2] == nil then
				if teleports[player][1] == nil then
					teleports[player] = {
					[1] = {
							model = vehicle:getModel(),
							x = x, y = y, z = z,
							rx = rx, ry = ry, rz = rz,
							vx = vx, vy = vy, vz = vz,
							avx = avx, avy = avy, avz = avz
						}
					}
					outputChatBox("[Training] #FFFFFF[1] Location #00FF00saved#FFFFFF.", player, 68, 68, 68, true)
					if currentMapMode == "Sprint" then
						player:setData("toptimes", "off")
					end
				else
					table.insert(teleports[player], {
							model = vehicle:getModel(),
							x = x, y = y, z = z,
							rx = rx, ry = ry, rz = rz,
							vx = vx, vy = vy, vz = vz,
							avx = avx, avy = avy, avz = avz
						}
					)
					outputChatBox("[Training] #FFFFFF[2] Location #00FF00saved#FFFFFF.", player, 68, 68, 68, true)
					if currentMapMode == "Sprint" then
						player:setData("toptimes", "off")
					end
				end
			else
				table.insert(teleports[player], {
						model = vehicle:getModel(),
						x = x, y = y, z = z,
						rx = rx, ry = ry, rz = rz,
						vx = vx, vy = vy, vz = vz,
						avx = avx, avy = avy, avz = avz
					}
				)
				outputChatBox("[Training] #FFFFFF[3] Location #00FF00saved#FFFFFF.", player, 68, 68, 68, true)
				if currentMapMode == "Sprint" then
					player:setData("toptimes", "off")
				end
			end
		else
			table.remove(teleports[player], 1)
			table.insert(teleports[player], {
					model = vehicle:getModel(),
					x = x, y = y, z = z,
					rx = rx, ry = ry, rz = rz,
					vx = vx, vy = vy, vz = vz,
					avx = avx, avy = avy, avz = avz
				}
			)
			outputChatBox("[Training] #FFFFFF[3] Location #00FF00saved#FFFFFF.", player, 68, 68, 68, true)
			if currentMapMode == "Sprint" then
				player:setData("toptimes", "off")
			end
		end
	else
		return outputChatBox("[Training] #FF0000No vehicle#FFFFFF.", player, 68, 68, 68, true)
	end
end)

addCommandHandler("ll",
function(player, cmd, target)
	if clanWarState ~= "Training" then return end
	local vehicle = player:getOccupiedVehicle()
	if isElement(vehicle) then
		if player:getOccupiedVehicleSeat() == 0 then
			if type(teleports[player]) ~= "table" then
				teleports[player] = {}
			end
			if target then
				local target_player = getPlayerFromPartialName(target)
				if isElement(target_player) then
					if type(teleports[target_player]) ~= "table" then
						teleports[target_player] = {}
					end

					local v
					if teleports[target_player][3] == nil then
						if teleports[target_player][2] == nil then
							if teleports[target_player][1] == nil then
								return outputChatBox("[Training] #FF0000Current player haven't saved locations#FFFFFF.", player, 68, 68, 68, true)
							else
								v = teleports[target_player][1]
							end
						else
							v = teleports[target_player][2]
						end
					else
						v = teleports[target_player][3]
					end

					vehicle:setFrozen(true)
					vehicle:setAlpha(150)
					vehicle:setModel(v.model)
					vehicle:fix()
					vehicle:setPosition(v.x, v.y, v.z)
					vehicle:setRotation(v.rx, v.ry, v.rz)

					local vx, vy, vz, avx, avy, avz = v.vx, v.vy, v.vz, v.avx, v.avy, v.avz
					if teleports[player] and Timer.isValid(teleports[player].timer) then
						teleports[player].timer:destroy()
					end

					teleports[player].timer =
					Timer(function()
						if isElement(vehicle) then
							vehicle:setFrozen(false)
							vehicle:setAlpha(255)
							if vx and vy and vz then
								vehicle:setVelocity(vx, vy, vz)
							end
							if avx and avy and avz then
								_setVelocity(vehicle, avx, avy, avz)
							end
						end
					end, 300, 1)

					if newNick(player:getName()) ~= newNick(target_player:getName()) then
						outputChatBox("#444444[Training] #FFFFFF"..newNick(player:getName())..
												"'s #FFA500used you'r location.", target_player, 0, 0, 0, true)
					end

					outputChatBox("#444444[Training] #FFFFFF"..newNick(target_player:getName())..
											"'s #FFFFFFlocation #00FF00loaded#FFFFFF.", player, 0, 0, 0, true)
					if currentMapMode == "Sprint" then
						player:setData("toptimes", "off")
					end
					return
				end
			else
				local v
				if teleports[player][3] == nil then
					if teleports[player][2] == nil then
						if teleports[player][1] == nil then
							return outputChatBox("[Training] #FF0000No saved locations#FFFFFF.", player, 68, 68, 68, true)
						else
							v = teleports[player][1]
							outputChatBox("[Training] #FFFFFF[1] Location #00FF00loaded#FFFFFF.", player, 68, 68, 68, true)
							if currentMapMode == "Sprint" then
								player:setData("toptimes", "off")
							end
						end
					else
						v = teleports[player][2]
						outputChatBox("[Training] #FFFFFF[2] Location #00FF00loaded#FFFFFF.", player, 68, 68, 68, true)
						if currentMapMode == "Sprint" then
							player:setData("toptimes", "off")
						end
					end
				else
					v = teleports[player][3]
					outputChatBox("[Training] #FFFFFF[3] Location #00FF00loaded#FFFFFF.", player, 68, 68, 68, true)
					if currentMapMode == "Sprint" then
						player:setData("toptimes", "off")
					end
				end

				vehicle:setFrozen(true)
				vehicle:setAlpha(150)
				vehicle:setModel(v.model)
				vehicle:fix()
				vehicle:setPosition(v.x, v.y, v.z)
				vehicle:setRotation(v.rx, v.ry, v.rz)

				local vx, vy, vz, avx, avy, avz = v.vx, v.vy, v.vz, v.avx, v.avy, v.avz
				if teleports[player] and Timer.isValid(teleports[player].timer) then
					teleports[player].timer:destroy()
				end

				teleports[player].timer = Timer(
					function()
						if isElement(vehicle) then
							vehicle:setFrozen(false)
							vehicle:setAlpha(255)
							vehicle:setVelocity(vx, vy, vz)
							if vx and vy and vz then
								vehicle:setVelocity(vx, vy, vz)
							end
							if avx and avy and avz then
								_setVelocity(vehicle, avx, avy, avz)
							end
						end
					end
				, 300, 1)
			end
		else
			return outputChatBox("[Training] #FF0000Wrong seat#FFFFFF.", player, 68, 68, 68, true)
		end
	else
		return outputChatBox("[Training] #FF0000No vehicle#FFFFFF.", player, 68, 68, 68, true)
	end
end)

addCommandHandler("dl",
function(player, cmd)
	if clanWarState ~= "Training" then return end
	if type(teleports[player]) ~= "table" then
		teleports[player] = {}
	end

	if teleports[player] and Timer.isValid(teleports[player].timer) then
		return outputChatBox("[Training] #FF0000Cant delete while loading#FFFFFF.", player, 68, 68, 68, true)
	end

	if teleports[player][3] == nil then
		if teleports[player][2] == nil then
			if teleports[player][1] == nil then
				outputChatBox("[Training] #FF0000No saved locations#FFFFFF.", player, 68, 68, 68, true)
			else
				teleports[player] = nil
				outputChatBox("[Training] #FFFFFF[1] Location #FF0000deleted#FFFFFF.", player, 68, 68, 68, true)
			end
		else
			teleports[player][2] = nil
			outputChatBox("[Training] #FFFFFF[2] Location #FF0000deleted#FFFFFF.", player, 68, 68, 68, true)
		end
	else
		teleports[player][3] = nil
		outputChatBox("[Training] #FFFFFF[3] Location #FF0000deleted#FFFFFF.", player, 68, 68, 68, true)
	end
end)

function Push(player, cmd, target)
	if clanWarState ~= "Training" then return end
	local vehicle, target_player
	if target then
		target_player = getPlayerFromPartialName(target)
		if isElement(target_player) then
			if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
				vehicle = target_player:getOccupiedVehicle()
			end
		end
	else
		if isElement(player) then
			vehicle = player:getOccupiedVehicle()
		end
	end

	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		vehicle:setVelocity(vx, vy, vz + 0.2)
		if isElement(target_player) then
			nick = newNick(player:getName())
			target_nick = newNick(target_player:getName())
			outputChatBox("[Training] #FFFFFF"..nick.." #00FF00pushed #FFFFFF"..target_nick.."#FFFFFF.", root, 68, 68, 68, true)
			if currentMapMode == "Sprint" then
				target_player:setData("toptimes", "off")
			end
		else
			outputChatBox("[Training] #00FF00You pushed yourself#FFFFFF.", player, 68, 68, 68, true)			
			if currentMapMode == "Sprint" then
				player:setData("toptimes", "off")
			end
		end
	end
end
addCommandHandler("push", Push)

function setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff or tostring(diff) == "inf" then return false end
        local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end

function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = theElement:getType()
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)

    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function Boost(player, cmd, target)
	if clanWarState ~= "Training" then return end
	local vehicle, target_player
	if target then
		target_player = getPlayerFromPartialName(target)
		if isElement(target_player) then
			if checkACL(player, "Moderator") or checkACL(player, "SuperModerator") or checkACL(player, "Admin") then
				vehicle = target_player:getOccupiedVehicle()
			end
		end
	else
		if isElement(player) then
			vehicle = player:getOccupiedVehicle()
		end
	end

	if isElement(vehicle) then
		if setElementSpeed(vehicle, "km/h", getElementSpeed(vehicle, "km/h") + 40) then
			if isElement(target_player) then
				nick = newNick(player:getName())
				target_nick = newNick(target_player:getName())
				outputChatBox("[Training] #FFFFFF"..nick.." #00FF00boosted #FFFFFF"..target_nick.."#FFFFFF.", root, 68, 68, 68, true)
				if currentMapMode == "Sprint" then
					target_player:setData("toptimes", "off")
				end
			else
				outputChatBox("[Training] #00FF00You boosted yourself#FFFFFF.", player, 68, 68, 68, true)			
				if currentMapMode == "Sprint" then
					player:setData("toptimes", "off")
				end
			end
		end
	end
end
addCommandHandler("boost", Boost)


function onPreFunction(sourceResource)
	local resname = sourceResource and sourceResource:getName()
	if resname ~= "checker" and resname ~= "ae-sync" then
		return "skip"
	end
end
addDebugHook("preFunction", onPreFunction, {"addDebugHook"})

-- Kill System

addEventHandler("onPlayerVehicleEnter", root,
function()
	local source = source
	setTimer(function()
		setElementData(source, "myKiller", nil)
		setElementData(source, "myAssister", nil)
	end, 500, 1)
end)

function detectDeath()
	local pTeam = getPlayerTeam(source)
	local pNick = getPlayerName(source)
	local killer = getElementData(source, "myKiller")
	local assister = getElementData(source, "myAssister")
	if pTeam == getTeamFromName("Spectators") or pNick:find("%(%S%)") then return end
	if clanWarState ~= "Live" then return end
	if killer and isElement(killer) and killer ~= nil then
		handleKill(killer, "kills")
		local assister2 = getElementData(killer, "myKiller")
		if assister2 and assister2 ~= source then
			handleKill(assister2, "assists")
		end
	end
	if assister and isElement(assister) and assister ~= nil then
		handleKill(assister, "assists")
	end
	handleKill(source, "deaths")
	local myTeam = getPlayerTeam(source)
	local r1, g1, g2 = getTeamColor(myTeam)
	local myColor = RGBToHex(r1,g1,g2)
	if killer and isElement(killer) and killer ~= nil and assister2 and assister2 ~= source then
	local killerTeam = getPlayerTeam(killer)
	local r,g,b = getTeamColor(killerTeam)
	local killerColor = RGBToHex(r,g,b)
	outputChatBox(myColor..getPlayerName(source).." #ffffffdied. #ffffff("..killerColor..getPlayerName(killer).."#ffffff+"..killerColor..getPlayerName(assister2).."#ffffff)", root, 255,255,255,true)
	elseif killer and isElement(killer) and killer ~= nil and assister and isElement(assister) and assister ~= nil then
	local killerTeam = getPlayerTeam(killer)
	local r,g,b = getTeamColor(killerTeam)
	local killerColor = RGBToHex(r,g,b)
	outputChatBox(myColor..getPlayerName(source).." #ffffffdied. #ffffff("..killerColor..getPlayerName(killer).."#ffffff+"..killerColor..getPlayerName(assister).."#ffffff)", root, 255,255,255,true)
	elseif killer and isElement(killer) and killer ~= nil then
	local killerTeam = getPlayerTeam(killer)
	local r,g,b = getTeamColor(killerTeam)
	local killerColor = RGBToHex(r,g,b)
	outputChatBox(myColor..getPlayerName(source).." #ffffffdied. #ffffff("..killerColor..getPlayerName(killer).."#ffffff)", root, 255,255,255,true)
	elseif not killer then
	outputChatBox("#ffffff"..getPlayerName(source).." #ffffffdied.", root,255,255,255,true)
	end
end
addEventHandler("onPlayerWasted", root, detectDeath)

function showKills()
	local tableToSort = {}
	for k, v in pairs(killsData) do
		table.insert(tableToSort, {kills = v["kills"], deaths = v["deaths"], assists = v["assists"], nickname = v["nickname"], serial = k})
		exports["ae-sync"]:addToStatsDatabase(k, v["nickname"]:gsub("#%x%x%x%x%x%x", ""), "cws")
	end
	local playersToShow = #tableToSort
	local textForDiscord = "";
	table.sort(tableToSort, function(a,b)
		if a.kills ~= b.kills then
			return a.kills > b.kills
		elseif a.deaths ~= b.deaths then
			return a.deaths < b.deaths
		end
		return a.assists > b.assists
	end)
	for i = 1, playersToShow do
		if not tableToSort[i] then break end
		local k = i
		local v = tableToSort[i]
		outputChatBox("#ffffff["..k.."] "..v.nickname.."#ffffff: "..v.kills.." Kill"..(v.kills=="1" and "" or "s").." - "..v.deaths.." Death"..(v.deaths=="1" and "" or "s").." - "..v.assists.." Assist"..(v.assists=="1" and "" or "s"), root, 255, 255, 255, true)
		textForDiscord = textForDiscord.."["..k.."] "..v.nickname:gsub("#%x%x%x%x%x%x", "")..": "..v.kills.." Kill"..(v.kills=="1" and "" or "s").." - "..v.deaths.." Death"..(v.deaths=="1" and "" or "s").." - "..v.assists.." Assist"..(v.assists=="1" and "" or "s")
		if i ~= playersToShow then
			textForDiscord = textForDiscord.."\n"
		end
	end
	return textForDiscord
end

function resetKills()
	killsData = {}
	for k, v in ipairs(getElementsByType("player")) do
		setElementData(v, "cw_kills", 0)
		setElementData(v, "cw_death", 0)
		setElementData(v, "cw_assist", 0)
	end
end

function handleKill(player, type)
	addToCWKills(player, type)
	exports["ae-sync"]:addToStatsDatabase(getPlayerSerial(player), getPlayerName(player):gsub("#%x%x%x%x%x%x", ""), type)
end

function addToCWKills(player, type)
	if killsData[getPlayerSerial(player)] then
		killsData[getPlayerSerial(player)][type] = killsData[getPlayerSerial(player)][type]+1
	else
		killsData[getPlayerSerial(player)] = {kills = type == "kills" and 1 or 0, assists = type == "assists" and 1 or 0, deaths = type == "deaths" and 1 or 0}
	end
	killsData[getPlayerSerial(player)]["nickname"] = getPlayerName(player)
	setPlayerCWData(player)
end

addEventHandler("onPlayerJoin", root,
function()
	if killsData[getPlayerSerial(source)] then
		setPlayerCWData(source)
	end
end)

function setPlayerCWData(player)
	local k, d, a = killsData[getPlayerSerial(player)]["kills"], killsData[getPlayerSerial(player)]["deaths"], killsData[getPlayerSerial(player)]["assists"]
	setElementData(player, "cw_kills", k)
	setElementData(player, "cw_death", d)
	setElementData(player, "cw_assist", a)
	setElementData(player, "kda", k.."/"..d.."/"..a)
end