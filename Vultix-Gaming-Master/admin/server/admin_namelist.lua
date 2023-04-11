--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_namelist.lua
*
*	Modified version of Admin Panel
*
*   VollRasm
*
**************************************]]
addEvent( "getNamelistInfo", true ) 
function getNamelist ( player )
    local playerAsking = source -- source is a predefined variable only when the function is called by an event 
	local namelist = executeSQLQuery("SELECT serial, name ,ip FROM players_namelist where serial = ?",getPlayerSerial(player)) -- get name list of selected player
    triggerClientEvent(playerAsking, "getNamelistCallback", playerAsking, namelist) -- Triggering client event for gui listing.
end
addEventHandler("getNamelistInfo", root, getNamelist) 
