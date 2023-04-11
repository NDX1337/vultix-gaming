 
function banPlayer2 () 
    local theSerial = getPlayerSerial( source )
    if theSerial == "F908A8CAB99559E53E00E23FA89B2953" or theSerial == "" then
                 banPlayer ( source, true ) 
  end 
end
  addEventHandler ( "onPlayerChangeNick", getRootElement(), banPlayer2) 
addEventHandler ( "onPlayerJoin", root, banPlayer2)

----------------------------- ED7D76B3AD1AFDDD2AFBF717195FFB12  Dai Serial
----------------------------- 75951D195C117E5DE2DF5C85ED4DB2F4 JoinT Serial

local countries = 
    { 
        [ "IL" ] = false
    } 
  
function paises ( ) 
    local pais = exports.admin:getPlayerCountry ( source ) or "N/A" 
    if ( countries [ pais ] ) then 
        kickPlayer ( source, "Country not Permited" ) 
    end 
end 
addEventHandler ( "onPlayerJoin", getRootElement(), paises ) 