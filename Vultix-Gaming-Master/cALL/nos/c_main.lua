
g_Me = getLocalPlayer()
g_Root = getRootElement()
g_ResRoot = getResourceRootElement()

g_ScreenSize = { guiGetScreenSize() }

local isEditingPosition = false

c_NitroUpgradeID = 1010

g_Nos = 0
c_NosMax = 100
g_IsHoldingFire = false
g_NosState = false
g_NosStartTick = 0
g_ShowGauge = false
g_VehicleModelID = nil

g_NosRechargeTimer = nil
g_NosRefillState = false
g_RefillStartTick = 0


g_Settings = {
	DisplayGauge = false,
	GaugePosition = { g_ScreenSize[1] * 0.02, g_ScreenSize[2] * 0.6 },
	ControlStyle = "normal",
	SustainOnPickup = true,
	NosDuration = 20,
	NosRechargeDelay = 40,
	NosRechargeDuration = 0,
	KeepNosOnPlayerWasted = false,
	KeepNosOnVehicleChange = false
};


-- OzulusTR was here

function getVehicleNitro()
    return g_Nos
end

-- stops the NOS recharge timer
function DisposeTimer()
	g_NosRefillState = false
	if g_NosRechargeTimer ~= nil then
		killTimer(g_NosRechargeTimer)
		g_NosRechargeTimer = nil
	end
end


function Dispose()
	alert("Resetting NOS...")
	g_Nos = 0
	g_NosState = false
	g_VehicleModelID = nil
	NosStop()
	DisposeTimer()
end
addEvent("disableNosOnMapStarting",true)
addEventHandler("disableNosOnMapStarting", g_Root, Dispose)


function SaveVehicleNos(vehicle, sync)
	if not vehicle then return end
	setElementData(vehicle, "nos", g_Nos, sync or false)
end

function RestoreVehicleNos()
  local vehicle = getPedOccupiedVehicle(g_Me)
  if vehicle then
    local vehNos = getElementData(vehicle, "nos", false)
    if vehNos then
      g_Nos = vehNos
    end
  end
end

function SetupEvents()
	alert("Re-binding events")
	removeEventHandler("onClientResourceStop", g_ResRoot, Dispose)
	removeEventHandler("onClientMapStopping", g_Me, Dispose)
	removeEventHandler("onClientPlayerFinish", g_Me, Dispose)

	addEventHandler("onClientResourceStop", g_ResRoot, Dispose)
	addEventHandler("onClientMapStopping", g_Me, Dispose)
	addEventHandler("onClientPlayerFinish", g_Me, Dispose)
end


addEventHandler("onClientResourceStart", g_ResRoot,
	function()
		alert("onClientResourceStart")
		label = guiCreateLabel(0, 0, 200, 40, "Click anywhere on the screen to\nchange gauge position", false)
		guiSetFont(label, "default-bold-small")
		guiSetVisible(label, false)
		
		loadSettingsFromFile()
		
		triggerServerEvent("onRequestNosSettings", g_Me)
		
		bindKey("vehicle_fire", "both", ToggleNOS)
		bindKey("vehicle_secondary_fire", "both", ToggleNOS)
		g_ShowGauge = true
		SetupEvents()
		RestoreVehicleNos()
	end
)



addEventHandler("onClientMapStarting", g_Me, 
	function()
		alert("onClientMapStarting")
		g_Nos = 0
		g_NosState = false
		g_VehicleModelID = nil
		g_NosRefillState = false
	end
)



function NosStart()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then return end
	
	addVehicleUpgrade(vehicle, c_NitroUpgradeID)
	setControlState("vehicle_fire", true)
	g_NosState = true
	g_NosStartTick = getTickCount()
end


function NosStop()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then	return end
	
	removeVehicleUpgrade(vehicle, c_NitroUpgradeID)
	setControlState("vehicle_fire", false)
	g_NosState = false
	
	SaveVehicleNos(vehicle, true)
end


g_HandleNosControl = {
	
	-- hybrid-style NOS : fire once to start NOS, fire again to stop
	hybrid = function(state)
			if state == "down" then
				g_IsHoldingFire = true
				if not g_NosState then
					if g_Nos > 0 then
						NosStart()
					end
				else 
					NosStop()
				end
			else
				g_IsHoldingFire = false
			end
		
		end,

	-- NFS-style NOS : hold fire to start NOS, release to stop
	nfs = function(state)
			if state == "down" then
				g_IsHoldingFire = true
				if g_Nos > 0 then
					NosStart()
				end
			else
				g_IsHoldingFire = false
				NosStop()
			end

		end,

	-- Default game style : press fire to start.
	normal = function(state)
			if state == "down" then
				g_IsHoldingFire = true
				if not g_NosState then
					if g_Nos > 0 then
						NosStart()
					end
				end
			else
				g_IsHoldingFire = false
			end
		
		end
}


function ToggleNOS(key, state)
	if isEditingPosition then return end
	
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then return end

	-- We don't want a passenger to control NOS, to avoid inconsistent states.
	local driver = getVehicleOccupant(vehicle, 0)
	if driver ~= g_Me then return end
	
	g_HandleNosControl[g_Settings.ControlStyle](state)
end


addEvent("onClientScreenFadedIn", true)
addEventHandler("onClientScreenFadedIn", g_Root,
	function()
		SetupEvents()
		g_ShowGauge = true
	end
)


addEvent("onClientScreenFadedOut", true)
addEventHandler("onClientScreenFadedOut", g_Root,
	function ()
		g_ShowGauge = false
	end
)


function StartNosRechargeTimer()
	DisposeTimer()
	if g_Settings.NosRechargeDelay > 0 then
		alert("Starting gradual refill in "..g_Settings.NosRechargeDelay.." seconds.")
		g_NosRechargeTimer = setTimer(StartGradualRefillNos, g_Settings.NosRechargeDelay * 1000, 1, c_NosMax)
		local resourceSettings = getResourceFromName("hud")
		if (resourceSettings) then
			if (getResourceState(resourceSettings) == "running") then
				triggerEvent("rechargeState", localPlayer)
			end
		end
	elseif g_Settings.NosRechargeDelay == 0 then
		alert("Refilling NOS to max.")
		RefillNos(c_NosMax)
	end
end


function ConsumeNos()
	if not g_NosState then return end

	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then return end

	local driver = getVehicleOccupant(vehicle, 0)
	if driver ~= g_Me then return end

	local nitro = getVehicleUpgradeOnSlot(vehicle, 8)
	if not (type(nitro) == "number" and nitro ~= 0) then return end
	
	local ConsumptionRate = c_NosMax / (FPSAvg * g_Settings.NosDuration)
	
	if g_Nos > 0 then
		--outputDebugString("OnConsume: State="..tostring(g_NosState).."; NOS="..g_Nos.."; Diff="..tostring(getTickCount() - g_NosStartTick).."; Fps Avg="..FPSAvg)
		g_Nos = g_Nos - ConsumptionRate
		if getTickCount() - g_NosStartTick > 20000 then
			NosStart()
		end
	else
		alert("NOS depleted.")
		NosStop()
		StartNosRechargeTimer()
	end

	-- ??
	--SaveVehicleNos(vehicle) 
end



function StartGradualRefillNos(nosAmount)
	if g_NosRefillState then return end
	if g_Settings.NosRechargeDuration <= 0 then
		RefillNos(nosAmount)
	else
		alert("NOS refill flag set. Starting gradual refill.")
		g_RefillStartTick = getTickCount()
		g_NosRefillState = true
	end
end

function RefillNosGradual()
	if not g_NosRefillState then return end
	
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then return end
	
	local driver = getVehicleOccupant(vehicle, 0)
	if driver ~= g_Me then return end
	
	local refillRate = c_NosMax / (FPSAvg * g_Settings.NosRechargeDuration)
	
	local ticks = getTickCount()
	if g_Nos == 0 then
		g_RefillStartTick = ticks
	end
	
	if ticks - g_RefillStartTick > g_Settings.NosRechargeDuration * 1000 then
		g_NosRefillState = false
	else
		g_Nos = g_Nos + refillRate
	end
	
	if g_Nos > c_NosMax then
    	g_Nos = c_NosMax
    	g_NosRefillState = false
    	SaveVehicleNos(vehicle, true)
	end

end



local previous_hourcheck = -1
local previous_color = 0
function RenderGauge()
	if not (g_ShowGauge and g_Settings.DisplayGauge and g_Nos > 0) then return end
	
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then return end

	local driver = getVehicleOccupant(vehicle, 0)
	if driver ~= g_Me then return end

	local color
	local hour, minute = getTime()
	if previous_hourcheck ~= hour then
		color = ((hour > 19) or (hour >= 0 and hour < 6)) and tocolor(0, 255, 0) or tocolor(255, 255, 255)
		previous_color = color
	else
		color = previous_color
	end
	local nosangle = (g_Nos / c_NosMax) * 225 + 45
	
	--dxDrawImage(g_Settings.GaugePosition[1], g_Settings.GaugePosition[2], 100, 100, "gauge/nos_gauge.png", 0, 0, 0, color)
	--dxDrawImage(g_Settings.GaugePosition[1] + 45, g_Settings.GaugePosition[2] + 41, 10, 40, "gauge/nos_arrow.png", nosangle, 0, -11, tocolor(255, 0, 0))
end


addEventHandler("onClientRender", g_Root,
	function()
		CalcFps()
		RefillNosGradual()
		ConsumeNos()
		RenderGauge()
	end
)


function RefillNos(nos)
	g_Nos = nos
	
	if g_Nos > 0 then
		DisposeTimer()
	end
	
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle then
    SaveVehicleNos(vehicle, true)
  end
	
	if g_NosState then
		if not isSustainOnPickup() then
			NosStop()
		end
	else
		if g_IsHoldingFire then
			NosStart()
		end
	end
end

addEvent("onClientPickupNos", true)
addEventHandler("onClientPickupNos", g_Me, RefillNos)


function HandleVehicleChangeInternal()
	if g_NosState and isSustainOnPickup() then
		NosStart()
	else
		NosStop()
		if not g_Settings.KeepNosOnVehicleChange then
			DisposeTimer()
			g_Nos = 0
			SaveVehicleNos(vehicle, true)
		end
	end
end

function isSustainOnPickup()
	if g_Settings.ControlStyle == "nfs" then
		return true		-- Sustain always on for nfs mode
	end
	if g_Settings.ControlStyle == "normal" then
		return false	-- Sustain always off for normal mode
	end
	return g_Settings.SustainOnPickup
end


-- Turn off NOS when vehicle changes
addEvent("onClientVehicleChange", true)
addEventHandler("onClientVehicleChange", g_Me, 
	function(modelId)
		alert("onVehicleChange")
		local vehicle = getPedOccupiedVehicle(g_Me)
		if not vehicle then return end
		
		-- Vehicle is not changing after all...
		if getElementModel(vehicle) == modelId then return end

		g_VehicleModelID = modelId

		HandleVehicleChangeInternal()
	end
)


-- Check vehicle model change when reaching checkpoint
addEvent("onClientCheckpointReached", true)
addEventHandler("onClientCheckpointReached", g_Me,
	function(player, checkpointNum)
		--alert("onCheckpointReached")
		
		if not source or source ~= g_Me then return end
	
		local vehicle = getPedOccupiedVehicle(g_Me)
		if not vehicle then return end
		
		local vmodel = getElementModel(vehicle)

		if not g_VehicleModelID then g_VehicleModelID = vmodel end
		
		if g_VehicleModelID ~= vmodel then
			HandleVehicleChangeInternal()
		end
		
		g_VehicleModelID = vmodel
	
	end
)


-- Turn off NOS when player dies
addEventHandler("onClientPlayerWasted", g_Me, 
	function(killer, weapon, bodypart)
		alert("onClientPlayerWasted")
		NosStop()
		if not g_Settings.KeepNosOnPlayerWasted then
			DisposeTimer()
			g_Nos = 0
			SaveVehicleNos(vehicle, true)
		end
	end
)



addEvent("onClientUpdateNosSettings", true)
addEventHandler("onClientUpdateNosSettings", g_Me,
	function(settings)
		for k,v in pairs(settings) do
			local currentValue = g_Settings[k]
			alert(string.format("Setting '%s' has been set to '%s'", tostring(k), tostring(v)))
			if currentValue ~= v then
				g_Settings[k] = v
			end
		end
	end
)

