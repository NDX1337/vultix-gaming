

addEvent("onGamemodeMapStart")
addEventHandler("onGamemodeMapStart", root, function (map)
    local name = map:getInfo("name") or map.name
    sendDiscordMessage("🗺️ Map '"..name.."' started.")
end)

addEventHandler("onPlayerJoin", root,
    function ()
        sendDiscordMessage("📥 "..getPlayerName(source).." has joined the server.")
    end, true, "low-9999"
)


addEventHandler("onPlayerQuit", root,
    function (quitType, reason, responsible)
        local playerName = getPlayerName(source)
        if isElement(responsible) then
            if getElementType(responsible) == "player" then
                responsible = getPlayerName(responsible)
            else
                responsible = "Console"
            end
        else
            responsible = false
        end
        sendDiscordMessage("🚪 "..playerName.." has left the server.".. (quitType and (" ["..quitType..((quitType == "Kicked" or quitType == "Banned") and (responsible and " by "..responsible or "") or "").."]" .. (reason and " ("..reason..")" or "")) or ""))
    end
)

addEventHandler("onPlayerChangeNick", root,
    function (previous, nick)
        sendDiscordMessage("🏷️ "..previous.." is now known as "..nick)
    end
)

function findPlayerByName(name)
    local player = getPlayerFromName(name)
    if player then return player end
    for i, player in ipairs(getElementsByType("player")) do
        if string.find(string.gsub(getPlayerName(player):lower(),"#%x%x%x%x%x%x", ""), name:lower(), 1, true) then
            return player
        end
    end
    return false
end

function arrayHas(table, item)
    for k, v in ipairs(table) do
        if v == item then
            return true
        end
    end
    return false
end

addEventHandler("onPlayerMute", root,
    function (state)
        if state == nil then
            return
        end

        if state then
            exports.discord:send("player.mute", { player = getPlayerName(source) })
        else
            exports.discord:send("player.unmute", { player = getPlayerName(source) })
        end
    end
)

function sendDiscordMessage(msg)
    if not msg then return end
    msg = msg:gsub("#%x%x%x%x%x%x", "")
    fetchRemote("http://"..serversIP..":5555/chat", {method = "POST", formFields = {message = msg, server = thisServer}}, function() end)
end

local allowedCommands = {"/ban", "/kick", "/warn"};



function onDiscordMessage(name, roles, message)
    local myTable = strsplit(" ", message)
    if not arrayHas(allowedCommands, myTable[1]:lower()) then
        outputChatBox("#69BFDB[Đ] #FFFFFF"..name..": #E7D9B0"..message, root, 255, 255, 255, true)
        sendDiscordMessage("[Đ] "..name..": "..message)
    elseif myTable[1]:lower() == "/warn" and arrayHas(roles, "855681545683206155") then
        table.remove(myTable, 1)
        local targetPlayer = findPlayerByName(myTable[1])
        if targetPlayer then
            dbQuery(function(queryHandler, targetPlayer, name2, playerName)
                local result = dbPoll(queryHandler, -1)
                if not isElement(targetPlayer) then return end
                local name1, playerSerial = getPlayerName(targetPlayer), getPlayerSerial(targetPlayer)
                local current = 0
                if #result == 1 then
                    local newCount = 0
                    if result[1]["count"] == 2 then
                        addBan(nil, nil, playerSerial, player, "warn", 6 * 60 * 60)  
                        current = 3
                    else
                        newCount = result[1]["count"]+1
                        current = newCount
                    end
                    outputChatBox("Updating "..playerSerial.." to "..newCount)
                    dbExec(handle, "UPDATE `warns` SET `count`=? WHERE `serial`=?", newCount, playerSerial)
                else
                    current = 1
                    dbExec(handle, "INSERT INTO `warns` (`count`, `serial`) VALUES(?, ?)", 1, playerSerial)
                end
                local message = "#69BFDB[Đ] #e60000[WARN] #ffffff"..name1.."#ffffff has been warned by "..name2.." #e60000["..current.."/3]"
                outputChatBox(message, root, 255, 255, 255, true)
                sendDiscordMessage(message)
            end, {targetPlayer, name, playerName}, handle, "SELECT `count` FROM `warns` WHERE `serial`=?", getPlayerSerial(targetPlayer))
        end
    elseif myTable[1]:lower() == "/kick" and arrayHas(roles, "855681545683206155") then
        table.remove(myTable, 1)
        local player = findPlayerByName(myTable[1])
        local reason = "No reason provided."
        if #myTable ~= 1 then
            table.remove(myTable, 1)
            reason = table.concat(myTable, " ")
        end
        if player then
            outputChatBox("#69BFDB[Đ] #FFFFFF"..getPlayerName(player).."#FFFFFF has been kicked by "..name.." from discord. ("..reason..")", root, 255, 255, 255, true)
            kickPlayer(player, name, reason)
        end
    elseif myTable[1]:lower() == "/ban" and arrayHas(roles, "855681545683206155") then
        table.remove(myTable, 1)
        local reason, player = "No reason provided.", false
        local seconds, timeText = 0, "permanent"
        if #myTable >= 2 then
            player = findPlayerByName(myTable[1])
            table.remove(myTable, 1)
            local number, period
            myTable[1]:gsub("%d+", function(i) number = i end)
            myTable[1]:gsub("%D", function(i) period = i end)
            if number and tonumber(number) > 0 then
                if period == "s" then
                    seconds, timeText = tonumber(number), number.." Second"..(number == "1" and "" or "s")
                elseif period == "m" then
                    seconds, timeText = tonumber(number)*60, number.." Minute"..(number == "1" and "" or "s")
                elseif period == "h" then
                    seconds, timeText = tonumber(number)*60*60, number.." Hour"..(number == "1" and "" or "s")
                elseif period == "d" then
                    seconds, timeText = tonumber(number)*60*60*24, number.." Day"..(number == "1" and "" or "s")
                else
                    return false
                end
            else
                if number ~= "0" or period then
                    return false
                end
            end
            if #myTable >= 2 then
                table.remove(myTable, 1)
                reason = table.concat(myTable, " ")
            end
        end
        if player then
            outputChatBox("#69BFDB[Đ] #FFFFFF"..getPlayerName(player).."#FFFFFF has been banned by "..name.." from discord. ("..timeText..") ("..reason..")", root, 255, 255, 255, true)
            banPlayer(player, false, false, true, name, reason, seconds)
        end
    end
end

function strsplit(delimiter, text)
    local list = {}
    local pos = 1
    if string.find("", delimiter, 1) then -- this would result in endless loops
       error("delimiter matches empty string!")
    end
    while 1 do
       local first, last = string.find(text, delimiter, pos)
       if first then -- found?
          table.insert(list, string.sub(text, pos, first-1))
          pos = last+1
       else
        table.insert(list, string.sub(text, pos))
          break
       end
    end
    return list
 end