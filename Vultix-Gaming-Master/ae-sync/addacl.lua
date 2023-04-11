function handleAddACL(playerSource, cmd, playerName, ...)
    local targetPlayer = findPlayerByName(playerName) 
    if not targetPlayer then
        outputChatBox("This player is not in the server", playerSource)
        return
    end
    local playerName = getPlayerName(targetPlayer)    
    local myTable = {...}
    local groupname = table.concat(myTable, " ")
    if groupname == "smod" then
        groupname = "SuperModerator"
    elseif  groupname == "jrdev" then
        groupname = "JRDev"
	elseif  groupname == "eventwinner" then
        groupname = "EventWinner"
    elseif groupname == "hadmin" then
        groupname = "HeadAdmin"
        groupname = "SuperModerator"
    elseif groupname == "hmod" then
        groupname = "HeadModerator"
    end
    local myGroup = false
    for k, v in ipairs(aclGroupList()) do
        if aclGroupGetName(v):lower() == groupname:lower() then
            myGroup = v
            groupname = aclGroupGetName(v)
            break
        end
    end
    if not myGroup then
        return outputChatBox("Couldn't find a group with the name '"..groupname.."'", playerSource)
    end
    local accName = getAccountName(getPlayerAccount(playerSource)) 
    local accToAdd = getAccountName(getPlayerAccount(targetPlayer))
    if isObjectInACLGroup("user."..accName, aclGetGroup("HeadAdmin")) or isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) or isObjectInACLGroup("user."..accName, aclGetGroup("Developer")) or isObjectInACLGroup("user."..accName, aclGetGroup("Owner")) then
        if ( ((groupname ~= "Owner" and groupname ~= "Co-Owner" and groupname ~= "HeadAdmin" and groupname ~= "Admin" and groupname ~= "+AE" and groupname ~= "Developer") or (isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) or isObjectInACLGroup("user."..accName, aclGetGroup("HeadAdmin"))) and groupname ~= "Owner" and groupname ~= "Co-Owner" and groupname ~= "Developer") or (isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) and groupname == "Co-Owner") or isObjectInACLGroup("user."..accName, aclGetGroup("Developer")) or isObjectInACLGroup("user."..accName, aclGetGroup("Owner")) ) then
            if not isGuestAccount (getPlayerAccount(targetPlayer)) then		
                aclGroupAddObject(myGroup, "user."..accToAdd)
                local thePlayer = getAccountPlayer (getAccount(accToAdd))
                outputChatBox("You've given '"..playerName.."' #00ff00"..aclGroupGetName(myGroup).." #ffffffsuccesfully!", playerSource,255,255,255,true)
                outputChatBox("You've been given #00ff00"..aclGroupGetName(myGroup).." #ffffffrights!", targetPlayer,255,255,255,true)
            else
                outputChatBox("This nibba is not logged in.", playerSource)	
            end
        else
            outputChatBox("You don't have access to do that!", playerSource)
        end
    elseif (isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) or isObjectInACLGroup("user."..accName, aclGetGroup("HeadModerator"))) and groupname == "SuperModerator" then
        if not isGuestAccount (getPlayerAccount(targetPlayer)) then		
            aclGroupAddObject(myGroup, "user."..accToAdd)
            local thePlayer = getAccountPlayer (getAccount(accToAdd))
            outputChatBox("You've given '"..playerName.."' #00ff00"..aclGroupGetName(myGroup).." #ffffffsuccesfully!", playerSource,255,255,255,true)
            outputChatBox("You've been given #00ff00"..aclGroupGetName(myGroup).." #ffffffrights!", targetPlayer,255,255,255,true)	
        else
            outputChatBox("This nibba is not logged in.", playerSource)	
        end
    end 
end
addCommandHandler("addacl", handleAddACL)

function handleDelACL(playerSource, cmd, playerName, ...)
    local targetPlayer = findPlayerByName(playerName) 
    if not targetPlayer then
        outputChatBox("This player is not in the server", playerSource)
        return
    end
    local playerName = getPlayerName(targetPlayer)    
    local myTable = {...}
    local groupname = table.concat(myTable, " ")
    if groupname == "smod" then
        groupname = "SuperModerator"
    elseif groupname =="jrdev" then
        groupname = "JRDev"
    elseif groupname =="eventwinner" then
        groupname = "EventWinner"
    elseif groupname == "hadmin" then
        groupname = "HeadAdmin"
    elseif groupname == "hmod" then
        groupname = "HeadModerator"
    end
    local myGroup = false
    for k, v in ipairs(aclGroupList()) do
        if aclGroupGetName(v):lower() == groupname:lower() then
            myGroup = v
            groupname = aclGroupGetName(v)
            break
        end
    end
    if not myGroup then
        return outputChatBox("Couldn't find a group with the name '"..groupname.."'", playerSource)
    end
    local accName = getAccountName(getPlayerAccount(playerSource)) 
    local accToAdd = getAccountName(getPlayerAccount(targetPlayer)) 
    if isObjectInACLGroup("user."..accName, aclGetGroup("HeadAdmin")) or isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) or isObjectInACLGroup("user."..accName, aclGetGroup("Developer")) or isObjectInACLGroup("user."..accName, aclGetGroup("Owner")) then
        if ( ((groupname ~= "Owner" and groupname ~= "Co-Owner" and groupname ~= "HeadAdmin" and groupname ~= "Admin" and groupname ~= "+AE" and groupname ~= "Developer") or (isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) or isObjectInACLGroup("user."..accName, aclGetGroup("HeadAdmin"))) and groupname ~= "Owner" and groupname ~= "Co-Owner" and groupname ~= "Developer") or (isObjectInACLGroup("user."..accName, aclGetGroup("Co-Owner")) and groupname == "Co-Owner") or isObjectInACLGroup("user."..accName, aclGetGroup("Developer")) or isObjectInACLGroup("user."..accName, aclGetGroup("Owner")) ) then
            if not isGuestAccount (getPlayerAccount(targetPlayer)) then		
                aclGroupRemoveObject(myGroup, "user."..accToAdd)
                local thePlayer = getAccountPlayer (getAccount(accToAdd))
                outputChatBox("You've removed '"..playerName.."' #e60000"..aclGroupGetName(myGroup).." #ffffffsuccesfully!", playerSource,255,255,255,true)
                outputChatBox("Your #e60000"..aclGroupGetName(myGroup).."#ffffff was removed!", targetPlayer,255,255,255,true)		
            else
                outputChatBox("This nibba is not logged in.", playerSource)	
            end
        else
            outputChatBox("You don't have access to do that!", playerSource)
        end
    elseif (isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) or isObjectInACLGroup("user."..accName, aclGetGroup("HeadModerator"))) and groupname == "SuperModerator" then
        if not isGuestAccount (getPlayerAccount(targetPlayer)) then		
            aclGroupRemoveObject(myGroup, "user."..accToAdd)
            local thePlayer = getAccountPlayer (getAccount(accToAdd))
            outputChatBox("You've removed '"..playerName.."' #e60000"..aclGroupGetName(myGroup).." #ffffffsuccesfully!", playerSource,255,255,255,true)
            outputChatBox("Your #e60000"..aclGroupGetName(myGroup).."#ffffff was removed!", targetPlayer,255,255,255,true)		
        else
            outputChatBox("This nibba is not logged in.", playerSource)	
        end
    end 
end
addCommandHandler("delacl", handleDelACL)


function handleWarn(player, cmd, playerName)
    local acc = getPlayerAccount(player)
    if not isGuestAccount(acc) and
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Developer")) or
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Owner")) or
                           isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Admin")) then
        local targetPlayer = findPlayerByName(playerName)
        if not targetPlayer then
            outputChatBox("Couldn't find a player with the name \""..playerName.."\"", player, 255, 255, 255, true)
            return
        end
        dbQuery(function(queryHandler, targetPlayer, player, playerName, playerSerial)
            local result = dbPoll(queryHandler, -1)
            if not isElement(targetPlayer) or not isElement(player) then return end
            local name1, name2 = getPlayerName(targetPlayer), getPlayerName(player)
            local current = 0
            if #result == 1 then
                local newCount = 0
                if result[1]["count"] == 2 then
                    addBan(nil, nil, playerSerial, player, "warn", 6 * 60 * 60)  
                    current = 3
                else
                    newCount = result[1]["count"]+1
                    current = newCount
                end
                dbExec(handle, "UPDATE `warns` SET `count`=? WHERE `serial`=?", newCount, playerSerial)
            else
                current = 1
                dbExec(handle, "INSERT INTO `warns` (`count`, `serial`) VALUES(?, ?)", 1, playerSerial)
            end
            local message = "#e60000[WARN] #ffffff"..name1.."#ffffff has been warned by "..name2.." #e60000["..current.."/3]"
            outputChatBox(message, root, 255, 255, 255, true)
            sendDiscordMessage(message)
        end, {targetPlayer, player, playerName, getPlayerSerial(targetPlayer)}, handle, "SELECT `count` FROM `warns` WHERE `serial`=?", getPlayerSerial(targetPlayer))
    end
end
addCommandHandler("warn", handleWarn)

function handleDeleteWarn(player, cmd, playerName)
    local acc = getPlayerAccount(player)
    if not isGuestAccount(acc) and
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Developer")) or
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Owner")) or
                           isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Admin")) then
        local targetPlayer = findPlayerByName(playerName)
        if not targetPlayer then
            outputChatBox("Couldn't find a player with the name \""..playerName.."\"", player, 255, 255, 255, true)
            return
        end
        dbQuery(function(queryHandler, targetPlayer, player, playerName, playerSerial)
            local result = dbPoll(queryHandler, -1)
            if not isElement(targetPlayer) or not isElement(player) then return end
            local name1, name2 = getPlayerName(targetPlayer), getPlayerName(player)
            if #result == 1 and result[1]["count"] ~= 0 then
                local newCount = result[1]["count"]-1
                dbExec(handle, "UPDATE `warns` SET `count`=? WHERE `serial`=?", newCount, playerSerial)
                local message = "#e60000[WARN] #ffffff"..name2.."#ffffff has removed a warn for "..name1.." #e60000["..newCount.."/3]"
                outputChatBox(message, root, 255, 255, 255, true)
                return sendDiscordMessage(message)
            end
            outputChatBox("#e60000[WARN] #ffffff"..name1.."#ffffff doesn't have any warns to be removed!", player, 255, 255, 255, true)
        end, {targetPlayer, player, playerName, getPlayerSerial(targetPlayer)}, handle, "SELECT `count` FROM `warns` WHERE `serial`=?", getPlayerSerial(targetPlayer))
    end
end
addCommandHandler("delwarn", handleDeleteWarn)

function handleWarnsQuery(player, cmd)
    dbQuery(function(queryHandler, player)
        local result = dbPoll(queryHandler, -1)
        if not isElement(player) then return end
        if #result == 1 and result[1]["count"] ~= 0 then
            return outputChatBox("#e60000[WARN] #ffffffYour warn count is: #e60000["..result[1]["count"].."/3]", player, 255, 255, 255, true)
        end
        outputChatBox("#e60000[WARN] #ffffffYou don't have any warns!", player, 255, 255, 255, true)
    end, {player}, handle, "SELECT `count` FROM `warns` WHERE `serial`=?", getPlayerSerial(player))
end
addCommandHandler("warns", handleWarnsQuery)