local serversPlayers = {}
local serversCW = {}
local openedPlayers = {}
local defaultCW = {status = "Free", teams = "?? vs ??", score = "0 : 0"}

function getCWData()
    local cwRes = getResourceFromName("cwdocipy")
    if getResourceState(cwRes) == "running" then
        return exports.cwdocipy:getDataForSync() or defaultCW
    end
    return defaultCW
end

for i = 1, #serverPorts do
    if i ~= thisServer then
        serversPlayers[i] = 0
        serversCW[i] = defaultCW
    else
        serversCW[i] = getCWData()
        serversPlayers[i] = #getElementsByType("player")
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    updatePlayersToAll()
    getPlayersFromAll()
    updateCWToAll(false)
    getCWFromAll()
end)

function getPlayersFromAll()
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            getPlayersFromServer(v)
        end
    end
end

function getCWFromAll()
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            getCWDataFromServer(v)
        end
    end
end

function getCWDataFromServer(serverHTTPPort)
    callRemote(serversIP..":"..serverHTTPPort, "default", 2, 1000, "ae-sync", "handleAnotherServerGetting", function(number, cwData)
        if number and number ~= "ERROR" then
            serversCW[number] = cwData or defaultCW
            updatePanelForPlayers("cw")
        end
    end, "cw")
end

function getPlayersFromServer(serverHTTPPort)
    callRemote(serversIP..":"..serverHTTPPort, "default", 2, 1000, "ae-sync", "handleAnotherServerGetting", function(number, count)
        if number and number ~= "ERROR" then
            serversPlayers[number] = count
            updatePanelForPlayers("count")
        end
    end, "count")
end

function updateCWToAll(hasData, data)
    if not hasData then
        data = getCWData()
    end
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            sendCWToServer(v, data)
        else
            serversCW[k] = data
            updatePanelForPlayers("cw")
        end
    end
    updateDiscordPanel({["type"] = "cw", ["cwData"] = json.encode(data), ["server"] = thisServer})
end

function sendCWToServer(serverHTTPPort, cwData)
    callRemote(serversIP..":"..serverHTTPPort, "default", 2, 1000, "ae-sync", "handleAnotherServerUpdating", function() end, "cw", thisServer, json.encode(cwData))
end

function handleAnotherServerGetting(type)
    if type == "count" then
        return thisServer, #getElementsByType("player")
    elseif type == "cw" then
        return thisServer, getCWData()
    end
end

function updatePlayersToAll(leave)
    local count = #getElementsByType("player")
    if leave then
        count = count-1
    end
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            sendPlayersToServer(v, count)
        else
            serversPlayers[k] = count
            updatePanelForPlayers("count")
        end
    end
    updateDiscordPanel({["type"] = "count", ["count"] = count, ["server"] = thisServer})
end

function updateDiscordPanel(data)
    fetchRemote("http://"..serversIP..":5555", {method = "POST", formFields = data}, function() end)
end

function sendCWScore(data)
    data["server"] = thisServer
    data["scoreData"] = json.encode(data["scoreData"])
    fetchRemote("http://"..serversIP..":5555", {method = "POST", formFields = data}, function() end)
end

function sendPlayersToServer(serverHTTPPort, count)
    callRemote(serversIP..":"..serverHTTPPort, "default", 2, 1000, "ae-sync", "handleAnotherServerUpdating", function() end, "count", thisServer, count)
end

function handleAnotherServerUpdating(type, sendingServer, data)
    if type == "count" then
        serversPlayers[sendingServer] = data
        updatePanelForPlayers(type)
    elseif type == "cw" then
        serversCW[sendingServer] = json.decode(data)
        updatePanelForPlayers(type)
    end
end

function updatePanelForPlayers(type)
    for k, v in ipairs(openedPlayers) do
        if type == "count" then
            triggerClientEvent(v, "onServerSendData", resourceRoot, serversPlayers)
        elseif type == "cw" then
            triggerClientEvent(v, "onServerSendData", resourceRoot, false, serversCW)
        end
    end
end

addEventHandler("onPlayerJoin", root, function() updatePlayersToAll() end)
addEventHandler("onPlayerQuit", root, function()
    updatePlayersToAll(true)
    if openedPlayers[getPlayerSerial(source)] then
        openedPlayers[getPlayerSerial(source)] = nil
    end
end)

addEvent("onClientAskForServerNumber", true)
addEventHandler("onClientAskForServerNumber", resourceRoot, function ()
    triggerClientEvent(client, "onServerSendServerNumber", resourceRoot, thisServer)
end)

addEvent("onClientOpenPanel", true)
addEventHandler("onClientOpenPanel", resourceRoot, function()
    openedPlayers[getPlayerSerial(client)] = client
    triggerClientEvent(client, "onServerSendData", resourceRoot, serversPlayers, serversCW)
end)

addEvent("onClientClosePanel", true)
addEventHandler("onClientClosePanel", resourceRoot, function()
    openedPlayers[getPlayerSerial(client)] = nil
end)

addEvent("onPlayerClickConnect", true)
addEventHandler("onPlayerClickConnect", resourceRoot, function(number)
    redirectPlayer(client, serversIP, serverPorts[number])
end)

function handleDiscordBotStart()
    local cwData = getCWData()
    updateDiscordPanel({["type"] = "cw", ["cwData"] = json.encode(cwData), ["server"] = thisServer})
    updateDiscordPanel({["type"] = "count", ["count"] = #getElementsByType("player"), ["server"] = thisServer})
end