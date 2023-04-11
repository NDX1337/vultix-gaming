timeInSeconds = {
    ["s"] = 1,
    ["sec"] = 1,
    ["m"] = 60,
    ["min"] = 60,
    ["h"] = 3600,
    ["d"] = 3600*24
}

local chatTimers = {}

addCommandHandler("mmute", function(source, cmdName, playerName, time)
    if isAdmin(source) or isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(source)), aclGetGroup('JRDev')) or isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(source)), aclGetGroup('HeadModerator')) then
        local player = findPlayerByName(playerName)
        if player then
            if player ~= source then
                local amount, type = string.match(time, "%d+"), string.match(time, "%a+")
                if timeInSeconds[type] then
                    local timestampForUnmute = getRealTime().timestamp + amount * timeInSeconds[type]
                    dbQuery(function(queryHandler, serial, timestampForUnmute, source, player)
                        if not isElement(source) or not isElement(player) then return end
                        local results = dbPoll(queryHandler, 0)
                        if #results ~= 0 then
                            if results[1]["timestamp"] > getRealTime().timestamp then
                                return outputChatBox("#ff0000[MMute] #ffffff"..getPlayerName(player).."#ffffff is already muted!", source, 255, 255, 255, true)
                            end
                            dbExec(handle, "UPDATE mmute SET timestamp=? WHERE serial=?", timestampForUnmute, serial)
                        else
                            dbExec(handle, "INSERT INTO mmute (serial, timestamp) VALUES (?, ?)", serial, timestampForUnmute)
                        end
                        setElementData(player, "mmute", timestampForUnmute)
                        setTimerForPlayerUnmute(player, timestampForUnmute-getRealTime().timestamp)
                        outputChatBox("#ff0000[MMute] #ffffff"..getPlayerName(player).."#ffffff has been #ff0000muted#ffffff by "..getPlayerName(source).."#ffffff ("..time..") (mainchat only)", root, 255, 255, 255, true)
                    end, {getPlayerSerial(player), timestampForUnmute, source, player}, handle, "SELECT timestamp FROM `mmute` WHERE `serial`=?", getPlayerSerial(player))
                else
                    outputChatBox("#ff0000[MMute] #ffffffWrong syntax, please use /mmute nick 30m", source, 255, 255, 255, true)
                end
            else
                outputChatBox("#ff0000[MMute] #ffffffYou can't mute yourself, idiot!", source, 255, 255, 255, true)
            end
        else
            outputChatBox("#ff0000[MMute] #ffffffCouldn't find anyone with the name \""..playerName.."#ffffff\".", source, 255, 255, 255, true)
        end
    else
        outputChatBox("#ff0000[MMute] #ffffffYou don't have permission to use this command!", source, 255, 255, 255, true)
    end
end)

addCommandHandler("unmmute", function(source, cmdName, playerName)
    if isAdmin(source) or isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(source)), aclGetGroup('JRDev')) or isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(source)), aclGetGroup('HeadModerator')) then
        local player = findPlayerByName(playerName)
        if player then
            dbQuery(function(queryHandler, serial, source, player)
                local results = dbPoll(queryHandler, 0)
                if #results ~= 0 then
                    if results[1]["timestamp"] < getRealTime().timestamp then
                        return outputChatBox("#ff0000[MMute] #ffffff"..getPlayerName(player).."#ffffff was not muted!", source, 255, 255, 255, true)
                    end
                    dbExec(handle, "UPDATE mmute SET timestamp=? WHERE serial=?", 0, serial)
                    removeTimerForPlayer(player)
                    setElementData(player, "mmute", false)
                    outputChatBox("#ff0000[MMute] #ffffff"..getPlayerName(player).."#ffffff has been #00ff00unmuted#ffffff by "..getPlayerName(source).."#ffffff (mainchat only)", root, 255, 255, 255, true)
                end
            end, {getPlayerSerial(player), source, player}, handle, "SELECT timestamp FROM `mmute` WHERE `serial`=?", getPlayerSerial(player))
        else
            outputChatBox("#ff0000[MMute] #ffffffCouldn't find anyone with the name \""..playerName.."#ffffff\".", source, 255, 255, 255, true)
        end
    else
        outputChatBox("#ff0000[MMute] #ffffffYou don't have permission to use this command!", source, 255, 255, 255, true)
    end
end)

addEventHandler("onPlayerJoin", root, function()
    dbQuery(function(queryHandler, player)
        local results = dbPoll(queryHandler, 0)
        if isElement(player) then
            if #results == 0 then
                setElementData(player, "mmute", 0)
            else
                setElementData(player, "mmute", results[1]["timestamp"])
                if results[1]["timestamp"] > getRealTime().timestamp then
                    setTimerForPlayerUnmute(player, results[1]["timestamp"]-getRealTime().timestamp)
                end
            end
        end
    end, {source}, handle, "SELECT timestamp FROM `mmute` WHERE `serial`=?", getPlayerSerial(source))
end)

addEventHandler("onPlayerQuit", root, function()
    removeTimerForPlayer(source)
end)

function removeTimerForPlayer(player)
    if chatTimers[getPlayerSerial(player)] and isElement(chatTimers[getPlayerSerial(player)]) then
        destroyElement(chatTimers[getPlayerSerial(player)])
        chatTimers[getPlayerSerial(player)] = nil
    end
end

function setTimerForPlayerUnmute(player, time)
    removeTimerForPlayer(player)
    chatTimers[getPlayerSerial(player)] = setTimer(sayPlayerIsUnmuted, time*1000, 1, player)
end

function sayPlayerIsUnmuted(player)
    if isElement(player) then
        outputChatBox("#ff0000[MMute] #ffffff"..getPlayerName(player).."#ffffff has been #00ff00unmuted#ffffff by System. (mainchat only)", root, 255, 255, 255, true)
    end
end