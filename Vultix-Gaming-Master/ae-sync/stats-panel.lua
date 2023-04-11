local x, y = guiGetScreenSize()
local width, height = 500, 250
local cx = (x / 2) - (width / 2)
local cy = (y / 2) - (height / 2)
local state = false
local statsTable = false

addEventHandler("onClientResourceStart", resourceRoot, function()
    statsWindow = guiCreateWindow(cx, cy, width, height, "Stats", false)
    guiWindowSetSizable(statsWindow, false)
    guiWindowSetMovable(statsWindow, false)
    guiSetVisible(statsWindow, false)
    closeButton = guiCreateButton(cx, cy - 35, 89, 27, "Close", false)
    guiSetVisible(closeButton, false)
    searchEdit = guiCreateEdit( cx+width/2, cy - 35, width/2, 27, "", false)
    guiSetVisible(searchEdit, false)
    statsGrid = guiCreateGridList(9, 21, width-18, 450, false, statsWindow)
    guiGridListAddColumn(statsGrid, "#", 0.1)
    guiGridListAddColumn(statsGrid, "Player", 0.20)
    guiGridListAddColumn(statsGrid, "KDA", 0.15)
    guiGridListAddColumn(statsGrid, "Kills", 0.15)
    guiGridListAddColumn(statsGrid, "Deaths", 0.15)
    guiGridListAddColumn(statsGrid, "Assists", 0.15)
    guiGridListAddColumn(statsGrid, "CWs", 0.15)
    guiSetFont(closeButton, "default-bold-small")
    guiSetProperty(closeButton, "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", closeButton, closePanel, false)
end)

function openPanel()
    state = true
    guiSetVisible(statsWindow, true)
    guiSetVisible(closeButton, true)
    guiSetVisible(searchEdit, true)
    showCursor(true)
    triggerServerEvent("onPlayerAskForStats", resourceRoot)
end

function closePanel()
    state = false
    guiSetVisible(statsWindow, false)
    guiSetVisible(closeButton, false)
    guiSetVisible(searchEdit, false)
    guiGridListClear(statsGrid)
    guiGridListAddRow(statsGrid, "Loading...")
    statsTable = false
    showCursor(false)
end

function setGridlist(table)
    statsTable = table
    guiGridListClear(statsGrid)
    for k, v in pairs(table) do
        if v.nickname:lower():find(guiGetText(searchEdit):lower()) then
            guiGridListAddRow(statsGrid, v.ranking, v.nickname, v.kdr, v.kills, v.deaths, v.assists, v.cws)
        end
    end
end
addEvent("setGridlist", true)
addEventHandler("setGridlist", resourceRoot, setGridlist)

addEventHandler("onClientGUIChanged", resourceRoot, function(element) 
    if element == searchEdit then
        if statsTable ~= false then
            guiGridListClear(statsGrid)
            for k, v in pairs(statsTable) do
                if v.nickname:lower():find(guiGetText(searchEdit):lower()) then
                    guiGridListAddRow(statsGrid, v.ranking, v.nickname, v.kdr, v.kills, v.deaths, v.assists, v.cws)
                end
            end
        end
    end
end)

function triggerWindow(source, command)
    if state then
        closePanel()
    else
        openPanel()
    end
end
addCommandHandler("stats", triggerWindow)
bindKey("F7", "down", triggerWindow)
