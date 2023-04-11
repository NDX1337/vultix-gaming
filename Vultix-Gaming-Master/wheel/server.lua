--#Change Spo/Wheel
local rims = {1025,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1096,1097,1098}
local spos = {1000, 1001, 1002, 1003, 1014, 1015, 1016, 1023, 1049, 1050, 1058, 1060, 1138, 1139, 1146, 1147, 1158, 1162, 1163, 1164}
local saveRims = {}
local saveSpos = {}

function changeRimDown(p)
 local pedOccupiedVehicle = getPedOccupiedVehicle( p )
 if pedOccupiedVehicle then
		if saveRims[getPlayerSerial(p)] == 0 or saveRims[getPlayerSerial(p)] == nil or saveRims[getPlayerSerial(p)] > 17 or saveRims[getPlayerSerial(p)] <= 0 or saveRims[getPlayerSerial(p)] == false then
			saveRims[getPlayerSerial(p)] = 1
		else
			saveRims[getPlayerSerial(p)] = saveRims[getPlayerSerial(p)] + 1
		end
			local id = rims [ saveRims[getPlayerSerial(p)] ]
		if id then
			addVehicleUpgrade( pedOccupiedVehicle, id )
		end
	end
end
addEvent("changerimdown",true)
addEventHandler("changerimdown",root,changeRimDown)


function changeRimUp(p)
	local pedOccupiedVehicle = getPedOccupiedVehicle( p )
	if pedOccupiedVehicle then
		if saveRims[getPlayerSerial(p)] == 0 or saveRims[getPlayerSerial(p)] == nil  or saveRims[getPlayerSerial(p)] <= 0 or saveRims[getPlayerSerial(p)] == false then
			saveRims[getPlayerSerial(p)] = 17
		else
			saveRims[getPlayerSerial(p)] = saveRims[getPlayerSerial(p)] - 1
		end
			local id = rims [ saveRims[getPlayerSerial(p)] ]
			if id then
				addVehicleUpgrade( pedOccupiedVehicle, id )
			end
	end
end
addEvent("changerimup",true)
addEventHandler("changerimup",root,changeRimUp)


function changeSpoDown(p)
 local pedOccupiedVehicle = getPedOccupiedVehicle( p )
	if pedOccupiedVehicle then
		if saveSpos[getPlayerSerial(p)] == 0 or saveSpos[getPlayerSerial(p)] == nil or saveSpos[getPlayerSerial(p)] > 17 or saveSpos[getPlayerSerial(p)] <= 0 or saveSpos[getPlayerSerial(p)] == false then
			saveSpos[getPlayerSerial(p)] = 1
		else
			saveSpos[getPlayerSerial(p)] = saveSpos[getPlayerSerial(p)] + 1
		end

		local id = spos [ saveSpos[getPlayerSerial(p)] ]
		if id then
			addVehicleUpgrade( pedOccupiedVehicle, id )
		end
	end
end
addEvent("changespodown",true)
addEventHandler("changespodown",root,changeSpoDown)


function changeSpoUp(p)
	local pedOccupiedVehicle = getPedOccupiedVehicle( p )
	if pedOccupiedVehicle then
		if saveSpos[getPlayerSerial(p)] == 0 or saveSpos[getPlayerSerial(p)] == nil  or saveSpos[getPlayerSerial(p)] <= 0 or saveSpos[getPlayerSerial(p)] == false then
			saveSpos[getPlayerSerial(p)] = 17
		else
			saveSpos[getPlayerSerial(p)] = saveSpos[getPlayerSerial(p)] - 1
		end
			local id = spos [ saveSpos[getPlayerSerial(p)] ]
			if id then
				addVehicleUpgrade( pedOccupiedVehicle, id )
			end
		end
end
addEvent("changespoup",true)
addEventHandler("changespoup",root,changeSpoUp)



addEventHandler("onPlayerVehicleEnter", root,
     function()
if  not saveRims[getPlayerSerial(source)] then
saveRims[getPlayerSerial(source)] = 1
end
        local veh = getPedOccupiedVehicle( source) 
		local id = rims[saveRims[getPlayerSerial(source)]]  
        addVehicleUpgrade( veh, id )
end
)

addEventHandler("onPlayerVehicleEnter", root,
     function()
if  not saveSpos[getPlayerSerial(source)] then
saveSpos[getPlayerSerial(source)] = 1
end
         local veh = getPedOccupiedVehicle( source) 
local id = spos[saveSpos[getPlayerSerial(source)]]  

               addVehicleUpgrade( veh, id )
    
end
)