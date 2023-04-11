-- Ignore

function handlePlayerChat(message, messageType)
    cancelEvent()
    if messageType ~= 0 and messageType ~= 2 then return end
    if messageType == 0 then
        local mmuteTime = getElementData(source, "mmute")
        if mmuteTime and mmuteTime > getRealTime().timestamp then
            return outputChatBox("say: You are muted", source, 255, 165, 0)
        elseif not exports["cwdocipy"]:canPlayerChat(source) then
            return false
        end
        sendDiscordMessage("**"..getPlayerName(source)..":** "..message)
    end
    local r, g, b = 255, 255, 255
    local team = getPlayerTeam(source)
    if team then
        r, g, b = getTeamColor(team)
    end
    local players = messageType == 0 and getElementsByType('player') or getPlayersInTeam(team)
    local prefix = messageType == 2 and "(TEAM) " or ""
    for k, v in ipairs(players) do
        if not isPlayerIgnoredBy(v, source) then
            outputChatBox(prefix..getPlayerName(source).."#e7d9b0: "..message, v, r, g, b, true)
        end
    end
end
addEventHandler("onPlayerChat", root, handlePlayerChat)

addEventHandler("onPlayerCommand", root,
    function(command)
        if (command == "msg" or command == "msg_target") then
            cancelEvent()
        end
    end
)

addCommandHandler("ignore", function(source, cmdName, playerName)
    local player = findPlayerByName(playerName)
    if player then
        if player ~= source then
            toggleIgnore(source, player)
        else
            outputChatBox("#123aef[Ignore] #ffffffYou can't ignore yourself, idiot!", source, 255, 255, 255, true)
        end
    else
        outputChatBox("#123aef[Ignore] #ffffffCouldn't find anyone with the name \""..playerName.."#ffffff\".", source, 255, 255, 255, true)
    end
end)

function isPlayerIgnoredBy(source, player)
    local ignoreTable = getElementData(source, "ignoreTable")
    if ignoreTable and ignoreTable[getPlayerSerial(player)] then
        return true
    end
    return false
end

function toggleIgnore(source, player)
    local ignoreTable = getElementData(source, "ignoreTable")
    if not ignoreTable then
        setElementData(source, "ignoreTable", {[getPlayerSerial(player)] = true})
        outputChatBox("#123aef[Ignore] #ffffffYou successfully #ff0000ignored \""..getPlayerName(player).."#ffffff\".", source, 255, 255, 255, true)
    else
        if not ignoreTable[getPlayerSerial(player)] then
            ignoreTable[getPlayerSerial(player)] = true
            outputChatBox("#123aef[Ignore] #ffffffYou successfully #ff0000ignored#ffffff \""..getPlayerName(player).."#ffffff\".", source, 255, 255, 255, true)
        else
            ignoreTable[getPlayerSerial(player)] = false
            outputChatBox("#123aef[Ignore] #ffffffYou successfully #00ff00unignored#ffffff \""..getPlayerName(player).."#ffffff\".", source, 255, 255, 255, true)
        end
        setElementData(source, "ignoreTable", ignoreTable)
    end
end