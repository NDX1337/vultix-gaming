local x,y = guiGetScreenSize()
local width,height = 500,250
local cx = (x/2) - (width/2)
local cy = (y/2) - (height/2)
local serial = "?"
local name = "?"
addEvent("reportPanel", true)
addEventHandler("reportPanel", getLocalPlayer(), function(serialx, namex)
guiSetInputMode("no_binds_when_editing")
  serial = serialx
  name = namex
  reportWindow = guiCreateWindow(cx,cy,width,height, "cReport", false)
  guiWindowSetSizable(reportWindow, false)
  guiWindowSetMovable(reportWindow, false)
  guiSetVisible(reportWindow, true)
  showCursor(true)
  kapat = guiCreateButton(cx,cy - 35, 89, 27, "Close", false)
  pNameLabel = guiCreateLabel(10, 25, 140, 27, "Player:",false,reportWindow)
  pNameEdit = guiCreateEdit(50, 20, 80, 27, "",false,reportWindow)
  reasonLabel = guiCreateLabel(10, 55, 140, 27, "Reason:",false,reportWindow)
  reasonEdit = guiCreateEdit(50, 50, 80, 27, "",false,reportWindow)
  descLabel = guiCreateLabel(10, 85, 140, 27, "Description:",false,reportWindow)
  descMemo = guiCreateMemo(80, 80, 220, 100, "Extra explanation goes here.",false,reportWindow)
  othersLabel = guiCreateLabel(10, 205, 140, 27, "Other Players:",false,reportWindow)
  othersEdit = guiCreateEdit(85, 200, 220, 27, "",false,reportWindow)
  ssLabel = guiCreateLabel(150, 55, 140, 27, "Screenshot:",false,reportWindow)
  ssEdit = guiCreateEdit(220, 50, 220, 27, "https://imgur.com/a/6rH41TX",false,reportWindow)
  add = guiCreateButton(325, 160, 100, 27, "Send", false, reportWindow)
  guiSetVisible(kapat, true)
  guiSetFont(kapat, "default-bold-small")
  guiSetProperty(kapat, "NormalTextColour", "FFAAAAAA")
  addEventHandler("onClientGUIClick", kapat, kapatButon, false)
  addEventHandler("onClientGUIClick", add, sendReport, false)
end)

function kapatButon()
  if kapat then
    guiSetVisible(reportWindow, false)
	guiSetVisible(kapat, false)
    showCursor(false)
  end
end

function sendReport()
local info = {}
info["pName"] = guiGetText(pNameEdit)
info["reason"] = guiGetText(reasonEdit)
info["description"] = guiGetText(descMemo)
info["others"] = guiGetText(othersEdit)
info["screenshot"] = guiGetText(ssEdit)
info["serial"] = serial
info["name"] = name
triggerServerEvent("sendReportDiscord", root, info)
end