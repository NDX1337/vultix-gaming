----------------- Anti-Bounce ----------------------
-- * The MIT License (MIT)
-- * 
-- * Copyright (c) 2016 Aleksi "Arezu" Lindeman and Jordy "Megadreams" Sleeubus
-- * 
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- * 
-- * The above copyright notice and this permission notice shall be included in all
-- * copies or substantial portions of the Software.
-- * 
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- * SOFTWARE.
---------------------------------------------------

--[[------------------
* We highly discourage
* directly editing the
* scripts. Please use
* the customization
* possibilities.
--------------------]]
----------------------
-- Variables
----------------------

Core = {}
Core = setmetatable({},{__index = Core})

Core.g_Root = getRootElement()
Core.g_ThisResource = Resource:getThis()
Core.g_ResourceRoot = Core.g_ThisResource:getRootElement()

Core.g_bABEnabled = true
Core.g_bDebugEnabled = false
Core.g_SettingsTable = {}

Core.g_bDebugHit = false
Core.g_DebugLastTick = 0
Core.g_Colliding = false
Core.g_preventBounceUpdateDelay = false

local oldTurnX, oldTurnY, oldTurnZ = 0, 0, 0
local turnDiffX, turnDiffY, turnDiffZ = 0, 0, 0

Core.g_ScreenW,Core.g_ScreenH = guiGetScreenSize()

Core.g_UsageTable = {
	["time_disabled"] = 0,
	["time_enabled"] = 0
}

Core.g_bouncesPrevented = 0

Core.g_LastCheck = 0

----------------------
-- Functions/Events
----------------------

function Core:onClientResourceStart()
	triggerServerEvent("onSettingsRequest",Core.g_ResourceRoot)
end
addEventHandler("onClientResourceStart",Core.g_ResourceRoot,Core.onClientResourceStart)

function Core:onClientResourceStop()
	if(Core.g_SettingsTable["bouncebind"]["disable"] == false) then
		unbindKey(Core.g_SettingsTable["bouncebind"]["value"],"up",Core.toggleBounce)
	end
	
	if(Core.g_SettingsTable["bouncecommands"]["disable"] == false) then
		for _,lCommand in pairs(split(Core.g_SettingsTable["bouncecommands"]["value"]:gsub(" ",""),",")) do
			removeCommandHandler(lCommand,Core.toggleBounce)
		end
	end
end
addEventHandler("onClientResourceStop",Core.g_ResourceRoot,Core.onClientResourceStop)

function Core.onSettingsReceived(lSettingsTable)
	Core.g_SettingsTable = lSettingsTable
	
	Preferences:loadPreferences()
	
	if(Core.g_SettingsTable["bouncecommands"]["disable"] == false and Core.g_SettingsTable["bouncebind"]["disable"] == false) then
			lShowMessage = lShowMessage:gsub("%%1","/"..tostring(Core.g_SettingsTable["bouncecommands"]["value"]:gsub(" ",""):gsub(","," /")))
			lShowMessage = lShowMessage:gsub("%%2",tostring(Core.g_SettingsTable["bouncebind"]["value"]))
			
			outputChatBox(lShowMessage,255,255,255,true)
	elseif(Core.g_SettingsTable["bouncecommands"]["disable"] == false or Core.g_SettingsTable["bouncebind"]["disable"] == false) then
			
			if(Core.g_SettingsTable["bouncebind"]["disable"] == false) then
				lShowMessage = lShowMessage:gsub("%%1",tostring(Core.g_SettingsTable["bouncebind"]["value"]))
			else
			end

	end
	
	
	if(Core.g_SettingsTable["bouncebind"]["disable"] == false) then
		bindKey(Core.g_SettingsTable["bouncebind"]["value"],"up",Core.toggleBounce)
	end
	
	if(Core.g_SettingsTable["bouncecommands"]["disable"] == false) then
		for _,lCommand in pairs(split(Core.g_SettingsTable["bouncecommands"]["value"]:gsub(" ",""),",")) do
			addCommandHandler(lCommand,Core.toggleBounce)
		end
	end
	
	Core.g_LastCheck = getRealTime().timestamp
	
	addCommandHandler("bouncedebug",Core.toggleDebug)
	
	addEventHandler("onClientPreRender",Core.g_Root,Core.onPreRender)
	addEventHandler("onClientRender",Core.g_Root,Core.onDebugRender)
	triggerEvent("onAntiBouncedLoaded",Core.g_Root)
end
addEvent("onSettingsReceived",true)
addEventHandler("onSettingsReceived",Core.g_ResourceRoot,Core.onSettingsReceived)

function Core:toggleBounce()
	Core.g_bABEnabled = not Core.g_bABEnabled
	
	if(Core.g_SettingsTable["togglemessage"]["disable"] == false) then
		if(Core.g_bABEnabled) then
			outputChatBox(Core.g_SettingsTable["togglemessage"]["value"]:gsub("%%1",Core.g_SettingsTable["enabledmessage"]["value"]),255,255,255,true)
		else
			outputChatBox(Core.g_SettingsTable["togglemessage"]["value"]:gsub("%%1",Core.g_SettingsTable["disabledmessage"]["value"]),255,255,255,true)
		end
	end

	Preferences:updatePreferences()
	triggerEvent("onAntiBounceToggled",Core.g_Root,Core.g_bABEnabled)
end

function Core:toggleDebug()
	Core.g_bDebugEnabled = not Core.g_bDebugEnabled
end

function Core:onUsageResetRequest()
	Core.g_UsageTable = {
		["time_disabled"] = 0,
		["time_enabled"] = 0
	}
end
addEvent("onUsageResetRequest",true)
addEventHandler("onUsageResetRequest",Core.g_Root,Core.onUsageResetRequest)

function Core:onPreRender()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle or not Core.g_bABEnabled then return end
	local tx, ty, tz = getVehicleTurnVelocity(vehicle)
	turnDiffX, turnDiffY, turnDiffZ = tx - oldTurnX, ty - oldTurnY, tz - oldTurnZ
	oldTurnX, oldTurnY, oldTurnZ = tx, ty, tz
	
	local normalX, normalY, normalZ = isVehicleOnGround(vehicle)
	if(normalX and not Core.g_Colliding)then
		preventBounce(vehicle, normalX, normalY, normalZ)
		Core.g_Colliding = true
	elseif (not normalX) then
		Core.g_Colliding = false
	end
	
	if(Core.g_preventBounceUpdateDelay)then
		setVehicleTurnVelocity(vehicle, 0, 0, 0)
		Core.g_preventBounceUpdateDelay = false
	end
end

function Core:onDebugRender()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	
	if not Core.g_bDebugEnabled then
		return
	end
	
	dxDrawText("== Anti-Bounce (v2.5.0) Debug ==", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(165), 0, 0, 
		tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
	
	if(Core.g_bABEnabled) then
		dxDrawText("State: #00ff00Enabled", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(150), 0, 0, tocolor(255, 255, 255, 255), conv(1), 
			"default","left","top",false,false,false,true)
	else
		dxDrawText("State: #ff0000Disabled", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(150), 0, 0, tocolor(255, 255, 255, 255), conv(1), 
			"default","left","top",false,false,false,true)
	end
	
	if(Core.g_bABEnabled) then
		Core.g_UsageTable["time_enabled"] = Core.g_UsageTable["time_enabled"] + (getRealTime().timestamp - Core.g_LastCheck)
	else
		Core.g_UsageTable["time_disabled"] = Core.g_UsageTable["time_disabled"] + (getRealTime().timestamp - Core.g_LastCheck)
	end

	Core.g_LastCheck = getRealTime().timestamp
	
	dxDrawText("Bounces prevented: "..Core.g_bouncesPrevented, Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(135), 0, 0, 
		tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
	
	dxDrawText("T Enabled: "..Core.g_UsageTable["time_enabled"], Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(120), 0, 0, 
		tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
		
	dxDrawText("T Disabled: "..Core.g_UsageTable["time_disabled"], Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(105), 0, 0, 
		tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
		
	if(Core.g_bDebugHit) then
		dxDrawText("#00ff00Bounce prevented", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(90), 0, 0, 
			tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
			
		dxDrawText("#3A85D6Collision with ground", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(75), 0, 0, 
			tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)	
			
		if((getTickCount() - Core.g_DebugLastTick) > 1000) then
			Core.g_bDebugHit = false
		end
	else
		if Core.g_Colliding then
			dxDrawText("#3A85D6Collision with ground", Core.g_ScreenW-conv(250), Core.g_ScreenH-conv(90), 0, 0, 
				tocolor(255, 255, 255, 255), conv(1), "default","left","top",false,false,false,true)
		end	
	end
end

function conv(size)
	local newSize = size*(Core.g_ScreenW/1366)
	return newSize
end

function getVectorDotProduct(vec, vec2)
	return vec[1]*vec2[1] + vec[2]*vec2[2] + vec[3]*vec2[3]
end

function getVectorLength(vec)
	return math.sqrt(vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3])
end

function normalizeVector(vec)
	local length = getVectorLength(vec)
	vec[1] = vec[1] / length
	vec[2] = vec[2] / length
	vec[3] = vec[3] / length
end

function getAngle(vec, vec2)
	return math.deg(math.acos(getVectorDotProduct(vec, vec2) / (getVectorLength(vec) * getVectorLength(vec2))))
end

function preventBounce(vehicle, normalX, normalY, normalZ)
	local matrix = getElementMatrix(vehicle)
	local positionRight = getMatrixRight(matrix)
	local positionLeft = getMatrixLeft(matrix)
	local positionDown = getMatrixDown(matrix)
	local normVec = {-normalX, -normalY, -normalZ}
	
	local vx, vy, vz = getElementVelocity(vehicle)
	local velVec = {vx, vy, vz}
	normalizeVector(velVec)
	
	local angleNormVel = getAngle(normVec, velVec)
	
	local angleRight = getAngle(positionRight, normVec)
	local angleLeft = getAngle(positionLeft, normVec)
	local angleDown = getAngle(positionDown, normVec)
	
	local tx, ty, tz = math.abs(turnDiffX), math.abs(turnDiffY), math.abs(turnDiffZ)
	if(angleRight > 75 and angleLeft > 75 and angleDown < 75 and (ty > 0.03 or tz > 0.03) and angleNormVel < 75)then
		Core.g_bDebugHit = true
		Core.g_DebugLastTick = getTickCount()
		
		Core.g_bouncesPrevented = Core.g_bouncesPrevented + 1
		Core.g_preventBounceUpdateDelay = true
		setVehicleTurnVelocity(vehicle, 0, 0, 0)
	end
end

function isVehicleOnGround(vehicle)
	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(vehicle)
	
	minZ = -getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
	
	local startX, startY, startZ = getPositionFromElementOffset(vehicle, minX, maxY, 0)
	local endX, endY, endZ = getPositionFromElementOffset(vehicle, minX, maxY, minZ)

	local lfWheelX,lfWheelY,lfWheelZ = getVehicleComponentPosition(localPlayer:getOccupiedVehicle(),"wheel_lf_dummy","world")
	
	if lfWheelX ~= false then
		startX,startY,startZ = lfWheelX,lfWheelY,lfWheelZ
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ * 0.6)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	else
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	end
	
	local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(startX, startY, startZ, endX, endY, endZ, true, false, false, true, true, true, false, true)

	if(hit)then
		return normalX, normalY, normalZ
	end
	
	startX, startY, startZ = getPositionFromElementOffset(vehicle, maxX, maxY, 0)
	endX, endY, endZ = getPositionFromElementOffset(vehicle, maxX, maxY, minZ)
	
	local lfWheelX,lfWheelY,lfWheelZ = getVehicleComponentPosition(localPlayer:getOccupiedVehicle(),"wheel_rf_dummy","world")
	if lfWheelX ~= false then
		startX,startY,startZ = lfWheelX,lfWheelY,lfWheelZ
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ * 0.6)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	else
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	end
	
	local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(startX, startY, startZ, endX, endY, endZ, true, false, false, true, true, true, false, true)
	if(hit)then
		return normalX, normalY, normalZ
	end
	
	startX, startY, startZ = getPositionFromElementOffset(vehicle, minX, minY, 0)
	endX, endY, endZ = getPositionFromElementOffset(vehicle, minX, minY, minZ)
	
	local lfWheelX,lfWheelY,lfWheelZ = getVehicleComponentPosition(localPlayer:getOccupiedVehicle(),"wheel_lb_dummy","world")
	if lfWheelX ~= false then
		startX,startY,startZ = lfWheelX,lfWheelY,lfWheelZ
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ * 0.6)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	else
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	end
	
	local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(startX, startY, startZ, endX, endY, endZ, true, false, false, true, true, true, false, true)
	if(hit)then
		return normalX, normalY, normalZ
	end

	startX, startY, startZ = getPositionFromElementOffset(vehicle, maxX, minY, 0)
	endX, endY, endZ = getPositionFromElementOffset(vehicle, maxX, minY, minZ)
	
	local lfWheelX,lfWheelY,lfWheelZ = getVehicleComponentPosition(localPlayer:getOccupiedVehicle(),"wheel_rb_dummy","world")
	if lfWheelX ~= false then
		startX,startY,startZ = lfWheelX,lfWheelY,lfWheelZ
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ * 0.6)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	else
		local checkPos = Matrix(Vector3(startX,startY,startZ),localPlayer:getOccupiedVehicle():getRotation()):transformPosition(Vector3(0,0,-math.abs(minZ)))
		endX,endY,endZ = checkPos.x,checkPos.y,checkPos.z
	end
	
	local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(startX, startY, startZ, endX, endY, endZ, true, false, false, true, true, true, false, true)
	if(hit)then
		return normalX, normalY, normalZ
	end
	
	return false
end

_getVehicleTurnVelocity = getVehicleTurnVelocity
function getVehicleTurnVelocity(vehicle)
	local turnX, turnY, turnZ = _getVehicleTurnVelocity(vehicle)
	local m = getElementMatrix(vehicle)
	local tx = turnX * m[1][1] + turnY * m[1][2] + turnZ * m[1][3]
	local ty = turnX * m[2][1] + turnY * m[2][2] + turnZ * m[2][3]
	local tz = turnX * m[3][1] + turnY * m[3][2] + turnZ * m[3][3]
	return tx, ty, tz
end

--[[
_setVehicleTurnVelocity = setVehicleTurnVelocity
function setVehicleTurnVelocity(vehicle, tx, ty, tz)
	local m = getElementMatrix(vehicle)
	local turnX = tx * m[1][1] + ty * m[1][2] + tz * m[1][3]
	local turnY = tx * m[2][1] + ty * m[2][2] + tz * m[2][3]
	local turnZ = tx * m[3][1] + ty * m[3][2] + tz * m[3][3]
	return _setVehicleTurnVelocity(vehicle, turnX, turnY, turnZ)
end
--]]
-- Taken from wiki.multitheftauto.com getElementMatrix example code
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getMatrixRight(m)
    return {m[1][1], m[1][2], m[1][3]}
end

function getMatrixLeft(m)
    return {-m[1][1], -m[1][2], -m[1][3]}
end

function getMatrixForward(m)
    return {m[2][1], m[2][2], m[2][3]}
end

function getMatrixBackward(m)
    return {-m[2][1], -m[2][2], -m[2][3]}
end

function getMatrixUp(m)
    return {m[3][1], m[3][2], m[3][3]}
end

function getMatrixDown(m)
    return {-m[3][1], -m[3][2], -m[3][3]}
end

function getMatrixPosition(m)
    return {m[4][1], m[4][2], m[4][3]}
end

addEvent("onAntiBouncedLoaded",false)
addEvent("onAntiBounceToggled",false)