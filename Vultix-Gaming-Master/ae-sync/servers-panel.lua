local totalServers = 12
local sX, sY = guiGetScreenSize()
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("onClientAskForServerNumber", resourceRoot)
    GUIEditor = {
        button = {},
        window = {},
        label = {players = {}, cwStatus = {}}
    }
    GUIEditor.window[1] = guiCreateWindow(150, 200, 1000, 480, "Servers Panel", false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    GUIEditor.label[1] = guiCreateLabel(48, 38, 176, 25, "Server", false, GUIEditor.window[1])
    GUIEditor.label[4] = guiCreateLabel(548, 38, 176, 25, "Server", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label[4], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[4], "center")
    GUIEditor.label[2] = guiCreateLabel(254, 41, 122, 20, "Players: Loading...", false, GUIEditor.window[1])
    GUIEditor.label[5] = guiCreateLabel(754, 41, 122, 20, "Players: Loading...", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label[5], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[5], "center")
    GUIEditor.label[3] = guiCreateLabel(350, 40, 165, 24, "ClanWar Status", false, GUIEditor.window[1])
    GUIEditor.label[6] = guiCreateLabel(850, 40, 165, 24, "ClanWar Status", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label[6], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[6], "center")
    GUIEditor.button[1] = guiCreateButton(20, 77, 227, 53, "Connect to Server 1", false, GUIEditor.window[1])
    GUIEditor.button[7] = guiCreateButton(520, 77, 227, 53, "Connect to Server 7", false, GUIEditor.window[1])

    GUIEditor.button[2] = guiCreateButton(20, 144, 227, 53, "Connect to Server 2", false, GUIEditor.window[1])
    GUIEditor.button[8] = guiCreateButton(520, 144, 227, 53, "Connect to Server 8", false, GUIEditor.window[1])

    GUIEditor.button[3] = guiCreateButton(20, 212, 227, 53, "Connect to Server 3", false, GUIEditor.window[1])
    GUIEditor.button[9] = guiCreateButton(520, 212, 227, 53, "Connect to Server 9", false, GUIEditor.window[1])

    GUIEditor.button[4] = guiCreateButton(20, 275, 227, 53, "Connect to Server 4", false, GUIEditor.window[1])
    GUIEditor.button[10] = guiCreateButton(520, 275, 227, 53, "Connect to Server 10", false, GUIEditor.window[1])

    GUIEditor.button[5] = guiCreateButton(20, 338, 227, 53, "Connect to Server 5", false, GUIEditor.window[1])
    GUIEditor.button[11] = guiCreateButton(520, 338, 227, 53, "Connect to Server 11", false, GUIEditor.window[1])

    GUIEditor.button[6] = guiCreateButton(20, 401, 227, 53, "Connect to Server 6", false, GUIEditor.window[1])
    GUIEditor.button[12] = guiCreateButton(520, 401, 227, 53, "Connect to Server 12", false, GUIEditor.window[1])
    
    GUIEditor.label.players[1] = guiCreateLabel(270, 93, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[7] = guiCreateLabel(770, 93, 80, 21, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.players[2] = guiCreateLabel(270, 160, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[8] = guiCreateLabel(770, 160, 80, 21, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.players[3] = guiCreateLabel(270, 228, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[9] = guiCreateLabel(770, 228, 80, 21, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.players[4] = guiCreateLabel(270, 292, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[10] = guiCreateLabel(770, 292, 80, 21, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.players[5] = guiCreateLabel(270, 356, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[11] = guiCreateLabel(770, 356, 80, 21, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.players[6] = guiCreateLabel(270, 418, 80, 21, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.players[12] = guiCreateLabel(770, 418, 80, 21, "Loading...", false, GUIEditor.window[1])

    guiLabelSetHorizontalAlign(GUIEditor.label.players[1], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[1], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[2], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[2], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[3], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[3], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[4], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[4], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[5], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[5], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[6], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[6], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[7], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[7], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[8], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[8], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[9], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[9], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[10], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[10], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[11], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[11], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.players[12], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.players[12], "center")

    GUIEditor.label.cwStatus[1] = guiCreateLabel(350, 86, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[7] = guiCreateLabel(850, 86, 172, 46, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.cwStatus[2] = guiCreateLabel(350, 142, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[8] = guiCreateLabel(850, 142, 172, 46, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.cwStatus[3] = guiCreateLabel(350, 213, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[9] = guiCreateLabel(850, 213, 172, 46, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.cwStatus[4] = guiCreateLabel(350, 277, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[10] = guiCreateLabel(850, 277, 172, 46, "Loading...", false, GUIEditor.window[1])

    GUIEditor.label.cwStatus[5] = guiCreateLabel(350, 338, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[11] = guiCreateLabel(850, 338, 172, 46, "Loading...", false, GUIEditor.window[1])
    
    GUIEditor.label.cwStatus[6] = guiCreateLabel(350, 401, 172, 46, "Loading...", false, GUIEditor.window[1])
    GUIEditor.label.cwStatus[12] = guiCreateLabel(850, 401, 172, 46, "Loading...", false, GUIEditor.window[1])
    
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[1], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[1], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[2], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[2], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[3], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[3], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[4], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[4], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[5], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[5], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[6], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[6], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[7], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[7], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[8], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[8], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[9], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[9], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[10], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[10], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[11], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[11], "center")
    guiLabelSetHorizontalAlign(GUIEditor.label.cwStatus[12], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label.cwStatus[12], "center")
    guiSetVisible(GUIEditor.window[1], false)
    for i = 1, totalServers do
        addEventHandler("onClientGUIClick", GUIEditor.button[i], function() triggerServerEvent("onPlayerClickConnect", resourceRoot, i) end)
    end
end)

bindKey("F6", "down", function()
    guiSetVisible(GUIEditor.window[1], not guiGetVisible(GUIEditor.window[1]))
    showCursor(guiGetVisible(GUIEditor.window[1]))
    if guiGetVisible(GUIEditor.window[1]) then
        triggerServerEvent("onClientOpenPanel", resourceRoot)
    else
        triggerServerEvent("onClientClosePanel", resourceRoot)
        guiSetText(GUIEditor.label[2], "Players: Loading...")
        guiSetText(GUIEditor.label[5], "Players: Loading...")
        for i = 1, totalServers do
            guiSetText(GUIEditor.label.players[i], "Loading...")
            guiSetText(GUIEditor.label.cwStatus[i], "Loading...")
        end
    end
end)

function handleServerSendData(serversPlayers, cwData)
    local total = 0
    for i = 1, totalServers do
        if serversPlayers then
            total = total + serversPlayers[i]
            guiSetText(GUIEditor.label.players[i], serversPlayers[i])
        end
        if cwData then
            guiSetText(GUIEditor.label.cwStatus[i], cwDataToString(cwData[i]))
        end
    end
    if serversPlayers then
        guiSetText(GUIEditor.label[2], "Players: "..total.." total")
        guiSetText(GUIEditor.label[5], "Players: "..total.." total")
    end
end
addEvent("onServerSendData", true)
addEventHandler("onServerSendData", resourceRoot, handleServerSendData)

function cwDataToString(cwData)
    return cwData.status.."\n"..cwData.score.."\n"..cwData.teams
end

addEvent("onServerSendServerNumber", true)
addEventHandler("onServerSendServerNumber", resourceRoot, function(number)
    guiSetEnabled(GUIEditor.button[number], false)
end)