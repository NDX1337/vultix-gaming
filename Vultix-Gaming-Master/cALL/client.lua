local cc = "#daa520"
outputChatBox("(/cradar) #daa520Customizable #ffffff0.20% CPU Radar",255,255,255,true)
local uMaskShader = dxCreateShader("hud_mask.fx")
local uMaskTexture = dxCreateTexture("files/circle.png")
addEvent ( "onClientMapStarting", true )
local SX, SY = guiGetScreenSize();
local starter = "no"
local canSend = "yes"
local canApply = "yes"
local backcolor, backalpha = "#000000", "180"
local roadcolor, roadalpha = "#abcdef", "255"
local radarsize, roadsize, blipsize = 4.5, 1, 82.5
local left, up = 1, 1

-- ********************************************************************************************************************************************************** --

-- RADAR POSITIONING
local iRadarScale = 1000; -- Default 1000. I guess no DD map is > 1000 ingame meter
local iRadarZoom = 4;
local iPlayerSize = SY / blipsize;
local blipr,blipg,blipb,blipa = 255,255,255,255
local Radar = {renderTarget = dxCreateRenderTarget(iRadarScale, iRadarScale, true)};
Radar.size = SY / radarsize;
Radar.radius = Radar.size / 2;
Radar.posX = SY / 20;
Radar.posY = SY - Radar.posX - Radar.size;
Radar.centerX = Radar.posX + Radar.size / 2;
Radar.centerY = Radar.posY + Radar.size / 2;

local Map = {minX = 0, minY = 0, maxX = 0, maxY = 0, centerX = 0, centerY = 0}; -- World map positions

local tblFilteredObjects 	= {}; -- All map objects that are supported
local tblModelValues 		= {}; -- Will temporary contain renderTarget and its sizes
local tblSupportedModelIDs 	= {
								-- Shades / Track objects
								[3458] = tocolor(192, 192, 192, 192), [8557] = tocolor(95, 50, 15, 150), [8558] = tocolor(95, 50, 15, 150), [8838] = tocolor(80, 95, 15, 150), [8947] = tocolor(92, 92, 92, 192), [6959] = tocolor(55, 55, 55, 192),
								[1660] = tocolor(192, 192, 192, 192),
								-- Breakables
								[1479] = tocolor(85, 150, 85, 192),
								-- Ramps
								--[1632] = tocolor(85, 85, 150, 192), [1633] = tocolor(85, 85, 150, 192), [1634] = tocolor(85, 85, 150, 192), [1635] = tocolor(85, 85, 150, 192), [5152] = tocolor(85, 85, 150, 192), [1245] = tocolor(85, 85, 150, 192),
								--[1696] = tocolor(85, 85, 150, 192), [1503] = tocolor(85, 85, 150, 192), [3080] = tocolor(85, 85, 150, 192),
							};
							  -- The amount of supported models is equal to the amount of temporary render targets--
-- ********************************************************************************************************************************************************** --

function radarSettings()
local x,y = guiGetScreenSize()
local width,height = 500,250
local cx = (x/2) - (width/2)
local cy = (y/2) - (height/2)

  radarWindow = guiCreateWindow(cx,cy,width,height, "Radar Settings", false)
  guiWindowSetSizable(radarWindow, false)
  guiWindowSetMovable(radarWindow, false)
  guiSetVisible(radarWindow, true)
  showCursor(true)
  closeButton = guiCreateButton(cx,cy - 35, 89, 27, "Close", false)
  guiSetVisible(closeButton, true)
  saveButton = guiCreateButton(345, 38.5, 100, 27, "Save", false, radarWindow)
  backLabel = guiCreateLabel(15,35,140,27, "Background color:", false, radarWindow)
  backColor = guiCreateEdit(120, 30, 80, 27, backcolor,false,radarWindow)
  backALabel = guiCreateLabel(200,35,140,27, "Alpha(0-255):", false, radarWindow)
  backAlpha = guiCreateEdit(280, 30, 60, 27, backalpha,false,radarWindow)
  roadLabel = guiCreateLabel(15,65,140,27, "Road color:", false, radarWindow)
  roadColor = guiCreateEdit(120, 60, 80, 27, roadcolor,false,radarWindow)
  roadALabel = guiCreateLabel(200,65,140,27, "Alpha(0-255):", false, radarWindow)
  roadAlpha = guiCreateEdit(280, 60, 60, 27, roadalpha,false,radarWindow)
  sizeLabel = guiCreateLabel(15,95,140,27, "Radar size:", false, radarWindow)
  sizeEdit = guiCreateEdit(120, 90, 80, 27, radarsize,false,radarWindow)
  blipLabel = guiCreateLabel(200,95,140,27, "Blip size:", false, radarWindow)
  blipSize = guiCreateEdit(280, 90, 60, 27, blipsize,false,radarWindow)
  zoomLabel = guiCreateLabel(15,125,140,27, "Radar zoom:", false, radarWindow)
  zoomEdit = guiCreateEdit(120, 120, 80, 27, iRadarZoom,false,radarWindow)
  roadSLabel = guiCreateLabel(200,125,140,27, "Road size:", false, radarWindow)
  roadSize = guiCreateEdit(280, 120, 60, 27, roadsize,false,radarWindow)
  leftLabel = guiCreateLabel(15,155,140,27, "Left-Right POS:", false, radarWindow)
  leftEdit = guiCreateEdit(120, 150, 80, 27, left,false,radarWindow)
  upLabel = guiCreateLabel(200,155,140,27, "Up-Down POS:", false, radarWindow)
  upEdit = guiCreateEdit(280, 150, 60, 27, up,false,radarWindow)
  addEventHandler("onClientGUIClick", closeButton, closePanel, false)
  addEventHandler("onClientGUIClick", saveButton, saveSettings, false)
end
addCommandHandler("cradar", radarSettings)

function closePanel()
    guiSetVisible(radarWindow, false)
	guiSetVisible(closeButton, false)
    showCursor(false)
end

-- HOTFIX : GETTOK 




function saveSettings()
local path = "radarsettings.txt"
if fileExists(path) then
fileDelete(path)
end
local file = fileCreate(path)
local backcolor, backalpha = guiGetText(backColor), guiGetText(backAlpha)
local roadcolor, roadalpha = guiGetText(roadColor), guiGetText(roadAlpha)
local setsize, blipsize, roadsize = guiGetText(sizeEdit), guiGetText(blipSize), guiGetText(roadSize)
local zoom = guiGetText(zoomEdit)
local left, up = guiGetText(leftEdit), guiGetText(upEdit)
fileWrite(file, backcolor..","..backalpha..","..roadcolor..","..roadalpha..","..setsize..","..blipsize..","..roadsize..","..zoom..","..left..","..up)
fileClose(file)
print("Radar settings saved.")
canApply = "yes"
applySettings()
onMapStarted();
end

function applySettings()
	if fileExists('radarsettings.txt') then
		if canApply == "yes" then
			setCameraClip (false,false)
			local path = "radarsettings.txt"
			local file = fileOpen(path)
			local size = fileGetSize(file)
			local settings = fileRead(file, size)
			fileClose(file)
			backcolor, backalpha = gettok(settings, 1, ',') or "#000000", gettok(settings, 2, ',') or "180"
			roadcolor, roadalpha = gettok(settings, 3, ',') or "#abcdef", gettok(settings, 4,',') or "255"
			radarsize, blipsize, roadsize = gettok(settings, 5, ',') or 4.5, gettok(settings, 6, ',') or 82.5, gettok(settings, 7, ',') or 1
			zoom = gettok(settings, 8, ',') or 4
			left, up = gettok(settings, 9, ',') or 1, gettok(settings, 10, ',') or 1
			Radar.size = SY / radarsize;
			iPlayerSize = SY / blipsize;
			iRadarZoom = zoom
			Radar.radius = Radar.size / 2;
			Radar.posX = SY / 20 ;
			Radar.posY = SY - Radar.posX - Radar.size;
			Radar.centerX = Radar.posX + Radar.size / 2;
			Radar.centerY = Radar.posY + Radar.size / 2;
			Radar.posY = SY - Radar.posX - Radar.size * up;
			Radar.posX = SY / 20 * left ;
			Radar.centerX = Radar.posX + Radar.size / 2;
			Radar.centerY = Radar.posY + Radar.size / 2;
			canApply = "no"
			print("Radar settings applied.")
		end
	else
		fileCreate('radarsettings.txt')	
	end

	
end
addEventHandler("onClientPlayerJoin", root, applySettings)
addEventHandler("onClientResourceStart", resourceRoot, applySettings); 

-- ********************************************************************************************************************************************************** --


local roads = 0
function toggleRoads()
	if roads == 0 then
		roads = 1
		onMapStarted();
		outputChatBox("#ffffffRoads #ff0000disabled.",200,0,0,true)
	elseif roads == 1 then
		roads = 0
		onMapStarted();
		outputChatBox("#ffffffRoads #00ff00enabled.",200,0,0,true)
	end	
end
bindKey("F1", "down", toggleRoads)

-- Pre-creation of the Render Target
function onMapStarted()
	
	setPlayerHudComponentVisible("all", false);
	Map.minX, Map.minY, Map.maxX, Map.maxY, Map.centerX, Map.centerY = 0, 0, 0, 0, 0, 0;
	
	local r, g, b = getColorFromString(backcolor)
	dxSetRenderTarget(Radar.renderTarget, true);
	dxDrawRectangle(0, 0, iRadarScale, iRadarScale, tocolor(r, g, b, backalpha));
	dxSetRenderTarget();

	getFilteredObjects();
	adjustMapCenter();
	if roads == 0 then
	renderFilteredObjects();
	end
	removeModelValues();

	dxSetShaderValue(uMaskShader, "sPicTexture", Radar.renderTarget);
	dxSetShaderValue( uMaskShader, "sMaskTexture", uMaskTexture);
end
addEventHandler("onClientResourceStart", resourceRoot, onMapStarted); 
addEventHandler("onClientMapStarting", root, onMapStarted);

function onClientRestore(bClearedRenderTargets)
onMapStarted();
end
addEventHandler("onClientRestore", root, onClientRestore);

function getFilteredObjects()
	for _, object in pairs(getElementsByType("object")) do
		local iModel = getElementModel(object);

		if (tblSupportedModelIDs[iModel]) then
			if (not tblModelValues[iModel]) then
				tblModelValues[iModel] = getModelValues(iModel);
				tblFilteredObjects[iModel] = {};
			end

			local posX, posY = getElementPosition(object);
			local rotX, rotY, rotZ = getElementRotation(object);

			getMinMaxPositions(posX, posY);
			
			table.insert(tblFilteredObjects[iModel], {rotX = math.rad(rotX), rotY = math.rad(rotY), rotZ = rotZ, posX = posX, posY = posY});
		end
	end
end

function getModelValues(iModel)
	local uTempObject = createObject(iModel, 0, 0, 0, 0, 0, 0); -- Create an temporary object at position 0 to get proper boundingBox results
	local iMinX, iMinY, iMinZ, iMaxX, iMaxY, iMaxZ = getElementBoundingBox(uTempObject);

	local iSizeX, iSizeY = iMaxX - iMinX, iMaxY - iMinY; -- Get the object X and Y size in world and at the same time for pixel size
	local uRenderTarget = dxCreateRenderTarget(iSizeX, iSizeY); -- Create a renderTarget

	dxSetBlendMode("modulate_add");
	dxSetRenderTarget(uRenderTarget);
	dxDrawRectangle(0, 0, iSizeX, iSizeY);
	dxSetRenderTarget();
	dxSetBlendMode("blend");

	destroyElement(uTempObject);

	return {img = uRenderTarget, sizeX = iSizeX, sizeY = iSizeY};
end

function renderFilteredObjects(uObject)
	dxSetBlendMode("modulate_add");
	dxSetRenderTarget(Radar.renderTarget);
	local r, g, b = getColorFromString(roadcolor)
	for model, modelObjects in pairs(tblFilteredObjects) do
		for _, object in pairs(modelObjects) do
			local posX, posY = convertCoordinatesToPixels(object.posX, object.posY);
			local sizeX = tblModelValues[model].sizeX
			local sizeY = tblModelValues[model].sizeY * roadsize
			dxDrawImage(posX - sizeX / 2 - 1, posY - sizeY / 2 - 1, sizeX + 2, sizeY + 2, tblModelValues[model].img, -object.rotZ, 0, 0, tocolor(0, 0, 0, 127)); -- Shadow
			dxDrawImage(posX - sizeX / 2, posY - sizeY / 2, sizeX, sizeY, tblModelValues[model].img, -object.rotZ, 0, 0, tocolor(r,g,b,roadalpha)); -- Object
		end
	end

	dxSetRenderTarget();
	dxSetBlendMode("blend");
end

function removeModelValues()
	for _, model in pairs(tblModelValues) do
		destroyElement(model.img);
		model.img = nil;
		model.sizeX = nil;
		model.sizeY = nil;
		model = nil;
	end

	tblFilteredObjects 	= {};
	tblModelValues = {};
end

-- ********************************************************************************************************************************************************** --

function renderRadar()
	if not getCameraTarget() then return end
	local posX, posY = getElementPosition(getCameraTarget());
	posX = (posX - Map.centerX) / iRadarScale;
	posY = (posY - Map.centerY) / -iRadarScale;
	local uCamTarget = getCameraTarget();

	if (uCamTarget) then	
		local _, _, iCameraRotation = getElementRotation(getCamera());
		local _, _, iVehicleRotation = getElementRotation(uCamTarget);

		dxSetShaderValue(uMaskShader, "gUVPosition", posX, posY);
		dxSetShaderValue(uMaskShader, "gUVScale", 1 / iRadarZoom, 1 / iRadarZoom);
		dxSetShaderValue(uMaskShader, "gUVRotAngle", math.rad(-iCameraRotation))
		dxDrawImage(Radar.posX, Radar.posY, Radar.size, Radar.size, uMaskShader);
		if getElementData(getLocalPlayer(), "state") == "alive" then
			dxDrawImage(Radar.posX + Radar.size / 2 - iPlayerSize / 1.5, Radar.posY + Radar.size / 2 - iPlayerSize / 1.5, iPlayerSize * 1.5, iPlayerSize * 1.5, "files/player.png", iCameraRotation - iVehicleRotation);
		end
		
		local iPlayerPosX, iPlayerPosY, iPlayerPosZ = getElementPosition(getCameraTarget());
		for id, player in ipairs(getElementsByType("player")) do
			if getElementData(player, "state") == "alive" and player ~= getLocalPlayer() then
				local veh = getPedOccupiedVehicle(player)
				if veh then
				local posX, posY, posZ = getElementPosition(veh)
				local iDistance = math.sqrt((posX - iPlayerPosX) ^ 2 + (posY - iPlayerPosY) ^ 2);
				local _, _, iCameraRotation = getElementRotation(getCamera());
				local iRotation = math.rad(findRotation(posX, posY, iPlayerPosX, iPlayerPosY) - iCameraRotation);
				local iRadius = math.min((iDistance / iRadarScale) * (Radar.size * iRadarZoom), Radar.radius - iPlayerSize);
				local iDiffZ = posZ - iPlayerPosZ;
				posX = Radar.centerX + math.sin(iRotation) * iRadius;
				posY = Radar.centerY + math.cos(iRotation) * iRadius;
				if getPlayerTeam(player) then
					blipr,blipg,blipb = getTeamColor(getPlayerTeam(player))
				else
					blipr,blipg,blipb = 255,255,255
				end
				if (iDiffZ > 3) then
					dxDrawImage(posX - iPlayerSize * 0.75, posY - iPlayerSize * 0.75, iPlayerSize * 1.5, iPlayerSize * 1.5, "files/blipup.png", 0, 0, 0, tocolor(blipr,blipg,blipb));
				elseif (iDiffZ < -3) then
					dxDrawImage(posX - iPlayerSize * 0.75, posY - iPlayerSize * 0.75, iPlayerSize * 1.5, iPlayerSize * 1.5, "files/blipdown.png", 0, 0, 0, tocolor(blipr,blipg,blipb));
				else
					dxDrawImage(posX - iPlayerSize * 0.75, posY - iPlayerSize * 0.75, iPlayerSize * 1.5, iPlayerSize * 1.5, "files/blip.png", 0, 0, 0, tocolor(blipr,blipg,blipb));
				end
			end
		end
	end
end
end
addEventHandler("onClientRender", root, renderRadar);

-- ********************************************************************************************************************************************************** --

function getMinMaxPositions(posX, posY)
	if (Map.minX == 0) then
		Map.minX, Map.maxX = posX, posX;
		Map.minY, Map.maxY = posY, posY;
		return false;
	end

	if (posX < Map.minX) then
		Map.minX = posX;
	else
		Map.maxX = (posX > Map.maxX) and posX or Map.maxX;
	end

	if (posY < Map.minY) then
		Map.minY = posY;
	else
		Map.maxY = (posY > Map.maxY) and posY or Map.maxY;
	end
end

function adjustMapCenter()
	Map.centerX = (Map.minX + Map.maxX) / 2;
	Map.centerY = (Map.minY + Map.maxY) / 2;
	iprint(Map.centerX, Map.centerY);
end

function convertCoordinatesToPixels(posX, posY) -- This will return pixel values from 0 to iRadarScale (default 1000) in order to draw it on the renderTarget
	return ((posX - Map.centerX) / iRadarScale + 0.5) * iRadarScale, ((posY - Map.centerY) / -iRadarScale + 0.5) * iRadarScale;
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

local radioMode = "true"
local currentChannel = 1
local radioChannel = nil
local streamTitle = nil
local radioChannels = {
    [1]={address="http://listen.181fm.com/181-uktop40_128k.mp3",Name="UK 181FM"},
    [2]={address="https://icecast-studio21.cdnvideo.ru/S21_2",Name="STUDIO 21"},
    [3]={address="http://radio.dubbase.fm/listen128.m3u",Name="DUBBASE"},
    [4]={address="http://air.radiorecord.ru:8102/yo_320",Name="Yo!"},
    [5]={address="http://air.radiorecord.ru:8102/teo_320",Name="Record Hardstyle"},
    [6]={address="http://air.radiorecord.ru:8102/rock_320",Name="Rock Radio Record"},
    [7]={address="http://air.radiorecord.ru:805/rap_320",Name="Record RAP"},
    [8]={address="http://air2.radiorecord.ru:805/trap_320",Name="Record TRAP"},
    [9]={address="http://icepool.silvacast.com/DEFJAYcom.mp3",Name="DEF JAY"},
	[10]={address="http://s2.free-shoutcast.com:18116/",Name="UK Drill"},
    [11]={address="http://blackstarradio.hostingradio.ru:8024/blackstarradio128.mp3",Name="Black Star Radio"},
	
}
function startRadio()
    radioChannel = playSound(getChannel(), true)
end

function stopRadio()
    stopSound(radioChannel)
	radioChannel = nil
end

function switchChannel()
    if (radioMode == "true") then
        stopRadio()
		currentChannel = currentChannel+1
		if currentChannel > #radioChannels then
		currentChannel = 1
		end
        startRadio()
    end
end
bindKey("N","down",switchChannel)

function getChannel(root)
    channelName = radioChannels[currentChannel].Name   
	outputChatBox(cc.."#ff0000[RADIO] #ffffff "..channelName,200,0,0,true)
    return radioChannels[currentChannel].address
end

addEventHandler("onClientSoundChangedMeta", root, function(streamTitle)
  if not(streamTitle2 == streamTitle) then
	if  streamTitle == ""  then
	local asd2 = nil
	else
	streamTitle2 = streamTitle
	outputChatBox(cc.."#ff0000[RADIO] #FFFFFF" .. streamTitle, 235, 221, 178, true)
	end
  else
    local asd = nil
  end
	
end)

function setRadio()
    if (radioMode == "true") then
        radioMode = "false"
		stopRadio()
		outputChatBox(cc.."#ffffffRadio #ff0000muted.",200,0,0,true)
    else
        radioMode = "true"
        startRadio()
       
    end
end
bindKey("M","down",setRadio)
startRadio()

function handleMinimize()
triggerServerEvent ( "gowno", root, localPlayer )
end
addEventHandler( "onClientMinimize", root, handleMinimize )

local smke = 0
texShader = dxCreateShader ( "files/smoke.fx" )
function vehsmke()
	if smke == 0 then
		engineApplyShaderToWorldTexture(texShader,"collisionsmoke")
		smke = 1
		outputChatBox("#ffffffSmoke #ff0000disabled.",200,0,0,true)
	elseif smke == 1 then
		engineRemoveShaderFromWorldTexture(texShader,"collisionsmoke")
		smke = 0
		outputChatBox("#ffffffSmoke #00ff00enabled.",200,0,0,true)
	end	
end
bindKey("F5","down",vehsmke)


