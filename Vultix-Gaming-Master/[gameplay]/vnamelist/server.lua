executeSQLQuery("CREATE TABLE IF NOT EXISTS voll_namelist (serial TEXT, name TEXT, ip TEXT)")

function onPlayerConnect() 
    local joinedPlayerName = getPlayerName ( source )
    joinedPlayerName = joinedPlayerName:gsub("#%x%x%x%x%x%x","")
    local theSerial = getPlayerSerial( source )
    --joinedPlayerName:gsub("#%x%x%x%x%x%x","") Without hex
    local result = executeSQLQuery("SELECT serial, name ,ip FROM players_namelist where name = ? and serial = ?",joinedPlayerName,theSerial)
    if(#result == 0) then
        executeSQLQuery("INSERT INTO players_namelist(serial,name,ip) VALUES(?,?,?)", theSerial, joinedPlayerName, getPlayerIP( source ) )
    end
end 
addEventHandler("onPlayerJoin", root, onPlayerConnect) 

function wasNickChangedByUser(oldNick, newNick, changedByUser)
    newNick = newNick:gsub("#%x%x%x%x%x%x","")
    local theSerial = getPlayerSerial( source )
	if (changedByUser == true) then -- check if the nickname was not changed by the user
        local result = executeSQLQuery("SELECT serial, name ,ip FROM players_namelist where name = ? and serial = ?",newNick,theSerial)
        if(#result == 0) then
            executeSQLQuery("INSERT INTO players_namelist(serial,name,ip) VALUES(?,?,?)", theSerial, newNick, getPlayerIP( source ) )
        end
	end 
end
addEventHandler("onPlayerChangeNick", root, wasNickChangedByUser) -- add an event handler