scoreboard = {
		{"ID","ID",5,35},
		{"Name","name", 5, 210},
		{"Country","countryCode", 5, 70},
		{"State","state", 5, 70},
		{"FPS","fps", 5, 50},
		{"Ping","ping", 5, 50},
	}
	
local tempPlayers = {}
local tempHeader = {}
local ids = {}

local columns = {}
local header = {}
local stWidth = 0
local maxSize = 0

for _,c in pairs(scoreboard) do
	columns[#columns+1] = {c[1],c[2],stWidth,c[4]}
	stWidth = stWidth + c[3] + c[4]
end
maxSize = stWidth

function sortPlayers() 

	local header = {}
	header[#header+1] = {"HEADER", ""..getServerName "" , #getElementsByType("player").."/"..getMaxPlayers()}
	header[#header+1] = {"Destruction Derby",#getElementsByType("player"),getMaxPlayers()}
	header[#header+1] = {"COLUMN",columns,stWidth}
	local players = {}
	for i,v in pairs(getElementsByType("player")) do
		if not getPlayerTeam(v) then
			players[#players+1] = {v}
		end
	end
	for _,team in pairs(getElementsByType("team")) do
		players[#players+1] = {team,#getPlayersInTeam(team)}
		for _,fp in pairs(getPlayersInTeam(team)) do
			players[#players+1] = {fp}
		end
	end
	tempPlayers[1] = players
	tempHeader[1] = header
	triggerClientEvent("Scoreboard:updatePlayers",root,tempPlayers,tempHeader)
end

function joinHandler()
	fetchRemote("http://ip-api.com/json/"..getPlayerIP(source),setCountry,"",false,source)
	local t = 1
	while ids[t] do
		t = t+1
	end
	ids[t] = source
	outputDebugString("Added "..getPlayerName(source).." to ID table with ID "..t)
	setElementData(source, "ID", t)
end
addEventHandler("onPlayerJoin", root, joinHandler)

addEventHandler("onPlayerQuit", root, 
	function()
		local i = getElementData(source, "ID")
		ids[i] = nil
		outputDebugString("Removed "..getPlayerName(source).." from ID table")
	end
)

addCommandHandler('setvultix', function(player, _, country)
 if (not country) then return end
 setElementData(player, 'countryCode', country)
end)

function setCountry(data, errno, player)
	if errno == 0 then
		local cData = fromJSON(data)
		setElementData(player,"countryCode",cData.countryCode)
		setElementData(player,"fullCountry",cData.country)
	end
end

function start()
	for i,v in pairs(getElementsByType("player")) do
		local t = 1
		while ids[t] do
			t = t+1
		end
		ids[t] = v
		outputDebugString("Added "..getPlayerName(v).." to ID table with ID "..t)
		setElementData(v, "ID", t)
		fetchRemote("http://ip-api.com/json/"..getPlayerIP(v),setCountry,"",false,v)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), start)

setTimer(sortPlayers,600,0)
