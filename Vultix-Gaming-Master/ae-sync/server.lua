serverPorts = {
    22003, 22006, 22009, 22012, 22016, 22019, 22023, 22025, 22027, 22029, 22031, 22033
}
serversToSynchronize = {
    "22006", "22009", "22012", "22015", "22019", "22022", "22024", "22026",
    "22028", "22030", "22032", "22034"
}
serversIP = "193.34.69.32"
for k, v in ipairs(serversToSynchronize) do
    if v == tostring(getServerHttpPort()) then thisServer = k end
end
local statsTable = {};
local statsSorted = {};

-- /login  /register  /chgpass (for admins)  /chgmypass (for users) /authserial  /addaccount

handle = dbConnect("mysql", "dbname=vultix;host=127.0.0.1;charset=utf8",
                   "vultix", "wJjj}9:9<H7>pP-q")
if not handle then
    outputChatBox("[AE-Sync] Database connection failed!", root, 255, 0, 0)
else
    outputDebugString("[AE-Sync] Database connected successfully.")
end

addEvent("aeSync:onClientCustomCommand", true)
addEventHandler("aeSync:onClientCustomCommand", resourceRoot,
                function(type, arg1, arg2)
    if type == "login" then
        dbQuery(function(queryHandler, player, username, password)
            if not isElement(player) or
                not isGuestAccount(getPlayerAccount(player)) then
                dbFree(queryHandler)
                if isElement(player) then
                    outputChatBox("login: You are already logged in", player,
                                  255, 168, 0)
                end
                return
            end
            local results = dbPoll(queryHandler, 0)
            if #results == 1 then
                if passwordVerify(password, results[1]["password"]) then
                    local isAuthorized = false
                    if results[1]["authorized_serials"] then
                        for k, v in ipairs(split(
                                               results[1]["authorized_serials"]),
                                           ",") do
                            if v == getPlayerSerial(player) then
                                isAuthorized = true
                            end
                        end
                    else
                        isAuthorized = true
                        dbExec(handle,
                               "UPDATE `accounts` SET `authorized_serials`=? WHERE `account_id`=?",
                               getPlayerSerial(player), results[1]["account_id"])
                    end
                    if isAuthorized then
                        local account = getAccount(username)
                        if account then
                            if not getAccount(username, results[1]["password"]) then
                                setAccountPassword(account,
                                                   results[1]["password"])
                            end
                        else
                            account = addAccount(username,
                                                 results[1]["password"])
                        end
                        logIn(player, account, results[1]["password"])
                        setElementData(player, "account_id",
                                       results[1]["account_id"])
                        handleIconData(player)
                        -- outputChatBox("login: You successfully logged in", player, 255, 168, 0) / Sent by default log-in system.
                    else
                        dbExec(handle,
                               "UPDATE `accounts` SET `last_serial_for_auth`=? WHERE `account_id`=?",
                               getPlayerSerial(player), results[1]["account_id"])
                        outputChatBox(
                            "login: Serial pending authorization for account '" ..
                                username ..
                                "' - See https://mtasa.com/authserial", player,
                            255, 168, 0)
                    end
                else
                    outputChatBox("login: Invalid password for account '" ..
                                      username .. "'", player, 255, 168, 0)
                end
            elseif #results == 0 then
                outputChatBox(
                    "login: No known account for '" .. username .. "'", player,
                    255, 168, 0)
            else
                outputChatBox(
                    "[AE-Sync] Found more than an account with the same username, please contact APOC.ZeYaD22#3377 to fix this issue.",
                    player, 255, 168, 0)
            end
        end, {client, arg1, arg2}, handle,
                "SELECT * FROM `accounts` WHERE username=?", arg1)
    elseif type == "register" then
        dbQuery(function(queryHandler, player, username, password)
            if not isElement(player) then
                dbFree(queryHandler)
                return
            end
            local results = dbPoll(queryHandler, 0)
            if #results == 0 then
                dbExec(handle,
                       "INSERT INTO `accounts` (`username`, `password`, `authorized_serials`) VALUES (?, ?, ?)",
                       username, passwordHash(password, "bcrypt", {}),
                       getPlayerSerial(player))
                outputChatBox(
                    "You have successfully registered! Username: '" .. username ..
                        "', Password: '" .. password .. "' (Remember it)",
                    player, 255, 100, 70)
            else
                outputChatBox(
                    "register: Account with this name already exists.", player,
                    255, 168, 0)
            end
        end, {client, arg1, arg2}, handle,
                "SELECT * FROM `accounts` WHERE username=?", arg1)
    elseif type == "chgpass" or type == "addaccount" or type == "authserial" then
        if hasObjectPermissionTo(client, "command." .. type) then
            if cmd == "chgpass" then
                dbQuery(function(queryHandler, player, username, password)
                    if not isElement(player) then
                        dbFree(queryHandler)
                        return
                    end
                    local results = dbPoll(queryHandler, 0)
                    if #results == 1 then
                        dbExec(handle,
                               "UPDATE `accounts` SET `password`=? WHERE `account_id`=?",
                               passwordHash(password, "bcrypt", {}),
                               results[1]["account_id"])
                        outputChatBox("chgpass: " .. username ..
                                          "'s password changed to '" .. password ..
                                          "'", player, 255, 100, 70)
                    elseif #results == 0 then
                        outputChatBox("chgpass: No known account for '" ..
                                          username .. "'", player, 255, 168, 0)
                    else
                        outputChatBox(
                            "[AE-Sync] Found more than an account with the same username, please contact APOC.ZeYaD22#3377 to fix this issue.",
                            player, 255, 168, 0)
                    end
                end, {client, arg1, arg2}, handle,
                        "SELECT * FROM `accounts` WHERE username=?", arg1)
            elseif type == "authserial" then
                dbQuery(function(queryHandler, player, username)
                    if not isElement(player) then
                        dbFree(queryHandler)
                        return
                    end
                    local results = dbPoll(queryHandler, 0)
                    if #results == 1 then
                        if results[1]["last_serial_for_auth"] then
                            outputChatBox(
                                "authserial: Successfully authorized " ..
                                    results[1]["last_serial_for_auth"] ..
                                    " to log into '" .. username .. "'", player,
                                255, 168, 0)
                            dbExec(handle,
                                   "UPDATE `accounts` SET `last_serial_for_auth`=?, `authorized_serials`=? WHERE `account_id`=?",
                                   false, results[1]["authorized_serials"] ..
                                       "," .. results[1]["last_serial_for_auth"])
                        else
                            outputChatBox(
                                "authserial: There isn't any recent new serial that tried to log into '" ..
                                    username "' !", player, 255, 168, 0)
                        end
                    elseif #results == 0 then
                        outputChatBox("authserial: No known account for '" ..
                                          username .. "'", player, 255, 168, 0)
                    else
                        outputChatBox(
                            "[AE-Sync] Found more than an account with the same username, please contact APOC.ZeYaD22#3377 to fix this issue.",
                            player, 255, 168, 0)
                    end
                end, {client, arg1}, handle,
                        "SELECT * FROM `accounts` WHERE username=?", arg1)
            elseif type == "addaccount" then -- Disabled from client-side anyway | UNFINISHED
                dbQuery(function(queryHandler, player, username, password)
                    if not isElement(player) then
                        dbFree(queryHandler)
                        return
                    end
                    local results = dbPoll(queryHandler, 0)
                    if #results == 0 then
                        dbExec(handle,
                               "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)",
                               username, passwordHash(password, "bcrypt", {}))
                        outputChatBox(
                            "You have successfully registered! Username: '" ..
                                username .. "', Password: '" .. password ..
                                "' (Remember it)", player, 255, 100, 70)
                    else
                        outputChatBox(
                            "addaccount: Account with this name already exists.",
                            player, 255, 168, 0)
                    end
                end, {client, arg1, arg2}, handle,
                        "SELECT * FROM `accounts` WHERE username=?", arg1)
            end
        else
            outputChatBox("ACL: Access denied for '" .. type .. "'", client,
                          255, 168, 0)
        end
    elseif type == "chgmypass" then
        if not isGuestAccount(getPlayerAccount(client)) then
            dbQuery(function(queryHandler, player, id, oldpass, newpass)
                if not isElement(player) then
                    dbFree(queryHandler)
                    return
                end
                local results = dbPoll(queryHandler, 0)
                if passwordVerify(oldpass, results[1]["password"]) then
                    dbExec(handle,
                           "UPDATE `accounts` SET `password`=? WHERE `account_id`=?",
                            passwordHash(newpass, "bcrypt", {}), id)
                    --[[
                        dbExec(handle,
                            "UPDATE `accounts` SET `password`=? WHERE `account_id`=?"
                             ,username,passwordHash(newpass, "bcrypt", {}), id)   
                    --]]
                    outputChatBox(
                        "chgmypass: Your password was changed to '" .. newpass ..
                            "'", player, 255, 168, 0)
                else
                    outputChatBox("chgmypass: Bad old password", player, 255,
                                  168, 0)
                end
            end, {client, getElementData(client, "account_id"), arg1, arg2},
                    handle, "SELECT * FROM `accounts` WHERE `account_id`=?",
                    getElementData(client, "account_id"))
        else
            outputChatBox(
                "chgmypass: You must be logged in to use this command", client,
                255, 168, 0)
        end
    end
end)

function startSynchronization(sourceResource, functionName, isAllowedByACL,
                              luaFilename, _, ...)
    if sourceResource == resource and luaFilename == "server.lua" then return end
    if not isAllowedByACL then return end
    local args = {...}
    local syncTime = getRealTime().timestamp
    local action, type
    if functionName == "banPlayer" or functionName == "addBan" or functionName ==
        "setBanNick" or functionName == "setBanAdmin" or functionName ==
        "removeBan" then
        action, type = "ban",
                       (functionName == "removeBan" and "remove" or "add")
        if functionName == "removeBan" then
            local ban = args[1]
            local serial = getBanSerial(ban)
            local ip = getBanIP(ban)
            if not serial and not ip then return end
            args = {["ip"] = ip, ["serial"] = serial}
        elseif functionName == "setBanNick" or functionName == "setBanAdmin" then
            if functionName == "setBanNick" then
                type = "setnick"
            elseif functionName == "setBanAdmin" then
                type = "setadmin"
            end
            local ban = args[1]
            local serial = getBanSerial(ban)
            local ip = getBanIP(ban)
            if not serial and not ip then return end
            args = {["ip"] = ip, ["serial"] = serial, ["name"] = args[2]}
        elseif functionName == "addBan" then
            -- [ string IP, string Username, string Serial, player responsibleElement, string reason, int seconds = 0 ]
            args = {
                ["ip"] = args[1],
                ["serial"] = args[3],
                ["responsible"] = (isElement(args[4]) and
                    getElementType(args[4]) == "player") and
                    getPlayerName(args[4]) or args[4],
                ["reason"] = args[5],
                ["seconds"] = args[6]
            }
        elseif functionName == "banPlayer" then
            -- player bannedPlayer, [ bool IP = true, bool Username = false, bool Serial = false, player/string responsiblePlayer = nil, string reason = nil, int seconds = 0 ] )
            if not isElement(args[1]) then return "skip" end
            setTimer(sendDataForSynchronization, 1000, 1, "ban", "setnick",
                     toJSON({
                ["ip"] = args[2] == true and getPlayerIP(args[1]) or nil,
                ["serial"] = args[4] == true and getPlayerSerial(args[1]) or nil,
                ["name"] = getPlayerName(args[1])
            }), getRealTime().timestamp + 1000)
            args = {
                ["ip"] = args[2] == true and getPlayerIP(args[1]) or nil,
                ["serial"] = args[4] == true and getPlayerSerial(args[1]) or nil,
                ["responsible"] = (isElement(args[5]) and
                    getElementType(args[5]) == "player") and
                    getPlayerName(args[5]) or args[5],
                ["reason"] = args[6],
                ["seconds"] = args[7]
            }
        end
    else
        action, type = "acl", (functionName == "aclGroupAddObject" and "add" or
                           "remove")
        args = {["group"] = aclGroupGetName(args[1]), ["object"] = args[2]}
    end
    sendDataForSynchronization(action, type, toJSON(args), syncTime)
end
addDebugHook("preFunction", startSynchronization, {
    "banPlayer", "addBan", "setBanNick", "setBanAdmin", "removeBan",
    "aclGroupAddObject", "aclGroupRemoveObject",
--[["aclCreate", "aclCreateGroup", "aclDestroy", "aclDestroyGroup", "aclGet", "aclGetGroup", "aclGetName", "aclGetRight", "aclGroupAddACL", "aclGroupAddObject", "aclGroupGetName", "aclGroupList", "aclGroupListACL", "aclGroupListObjects", "aclGroupRemoveACL", "aclGroupRemoveObject", "aclReload", "aclRemoveRight", "aclSave", "aclSetRight",]] })

function sendDataForSynchronization(action, type, args, syncTime)
    dbExec(handle,
           "INSERT INTO `synchronization` (`server_id`, `server_port`, `action`, `type`, `args`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?)",
           thisServer, serversToSynchronize[thisServer], action, type, args,
           syncTime)
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                       "handleSynchronization", function() end, action, type,
                       args, syncTime, i)
        end
    end
end

function addServerData(action, type, args, syncTime, serverID)
    dbExec(handle,
           "INSERT INTO `synchronization` (`server_id`, `server_port`, `action`, `type`, `args`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?)",
           serverID, serversToSynchronize[serverID], action, type, args,
           syncTime)
end

function handleSynchronization(action, type, args, syncTime)
    args = fromJSON(args)
    if action == "ban" then
        if type == "remove" or type == "setnick" or type == "setadmin" then
            for k, v in ipairs(getBans()) do
                if (getBanSerial(v) and getBanSerial(v) == args["serial"]) or
                    (getBanIP(v) and getBanIP(v) == args["ip"]) then
                    if type == "remove" then
                        removeBan(v)
                    elseif type == "setadmin" then
                        setBanAdmin(v, args["name"])
                    else
                        setBanNick(v, args["name"])
                    end
                end
            end
        else
            addBan(args["ip"] or nil, nil, args["serial"] or nil,
                   args["responsible"] or nil, args["reason"] or nil,
                   tonumber(args["seconds"]))
        end
    else
        local myGroup = aclGetGroup(args["group"])
        if myGroup then
            if type == "add" then
                if not isObjectInACLGroup(args["object"], myGroup) then
                    aclGroupAddObject(myGroup, args["object"])
                end
            else
                if isObjectInACLGroup(args["object"], myGroup) then
                    aclGroupRemoveObject(myGroup, args["object"])
                end
            end
        end
    end
    setLastUpdate(syncTime)
end

addEventHandler("onResourceStart", resourceRoot, function()
    local myAcc = getAccount("http_admin")
    if not myAcc then
        addAccount("http_admin", "be$tp4Ssvv0rd")
    end
    aclSave()
    for k, v in ipairs(getResources()) do
        if getResourceState(v) == "loaded" and getResourceInfo(v, 'type') ~= 'map' then
            startResource(v, true)
        end
    end
    executeSQLQuery("CREATE TABLE IF NOT EXISTS `lastSync` (`time` TEXT)")
    if executeSQLQuery("SELECT COUNT(*) FROM `lastSync`")[1]["COUNT(*)"] == 0 then
        executeSQLQuery("INSERT INTO `lastSync` (`time`) VALUES ('0')")
    end
    lastUpdated = getLastUpdate()
    outputDebugString("[AE-Sync] Synchronization is loading...")
    dbQuery(function(queryHandler)
        local results = dbPoll(queryHandler, 0)
        if #results == 0 then
            outputDebugString("[AE-Sync] Server ACL & Ban list is up to date!")
        else
            outputDebugString("[AE-Sync] Found " .. #results ..
                                  " updates to sync, starting...")
            updatesToSync = results
            handleDBUpdates()
        end
    end, handle,
            "SELECT * FROM `synchronization` WHERE `timestamp`>? ORDER BY `timestamp` ASC",
            lastUpdated)
    dbQuery(function(queryHandler)
        local results = dbPoll(queryHandler, 0)
        if #results ~= 0 then
            for k, v in ipairs(results) do
                statsTable[v["serial"]] = {
                    nickname = v.nickname,
                    kills = v.kills,
                    deaths = v.deaths,
                    assists = v.assists,
                    cws = v.cws
                }
            end
            updateSortedArray()
        end
    end, handle, "SELECT * FROM `stats`", lastUpdated)
end)

function handleDBUpdates()
    if #updatesToSync == 0 then
        outputDebugString(
            "[AE-Sync] ACL & Bans list have been successfully updated!")
        return
    end
    local v = updatesToSync[1]
    v["args"] = fromJSON(v["args"])
    if v["action"] == "ban" and v["type"] == "add" and
        tonumber(v["args"]["seconds"]) ~= 0 then
        if getRealTime().timestamp > tonumber(v["timestamp"]) +
            v["args"]["seconds"] then
            table.remove(updatesToSync, 1)
            setTimer(handleDBUpdates, 100, 1)
            return
        else
            v["args"]["seconds"] = v["args"]["seconds"] -
                                       (getRealTime().timestamp -
                                           tonumber(v["timestamp"]))
        end
    end
    handleSynchronization(v["action"], v["type"], toJSON(v["args"]),
                          v["timestamp"])
    table.remove(updatesToSync, 1)
    setTimer(handleDBUpdates, 100, 1)
end

addEventHandler("onResourceStop", resourceRoot, function()
    outputDebugString(
        "[AE-Sync] Account & ACL rights synchronization has stopped!")
end)

local disabledCommands = {
    ["login"] = true,
    ["register"] = true,
    ["chgpass"] = true,
    ["chgmypass"] = true,
    ["addaccount"] = true
}

addEventHandler("onPlayerCommand", root, function(command)
    if (disabledCommands[command]) then cancelEvent() end
end)

function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function findPlayerByName(name)
    local player = getPlayerFromName(name)
    if player then return player end
    for i, player in ipairs(getElementsByType("player")) do
        if string.find(string.gsub(getPlayerName(player):lower(),
                                   "#%x%x%x%x%x%x", ""), name:lower(), 1, true) then
            return player
        end
    end
    return false
end

function getLastUpdate()
    local myTime = executeSQLQuery("SELECT * FROM `lastSync`")
    return myTime[1].time
end

function setLastUpdate(time)
    lastUpdated = time
    executeSQLQuery("UPDATE `lastSync` SET `time`=?", time)
end

function handleCommand(player, cmd, action, resname)
    local acc = getPlayerAccount(player)
    if not isGuestAccount(acc) and
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Developer")) or
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Owner")) then
        if (action == "start" or action == "stop" or action == "restart") and
            resname then
            local isCorrect = false
            for k, v in ipairs(getResources()) do
                if (getResourceName(v):lower() == resname:lower()) then
                    resname = getResourceName(v)
                    isCorrect = true
                end
            end
            if not isCorrect then
                outputChatBox(
                    "[AE-Sync] Couldn't find a resource with this name \"" ..
                        resname .. "\"", player, 255, 168, 0)
                return
            else
                outputChatBox(
                    "[AE-Sync] Successfully "..action.."ing  \"" ..
                        resname .. "\"", player, 255, 168, 0)
            end
        end
        for k, v in ipairs(serversToSynchronize) do
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                       "handleSyncCommand", function() end, action, resname)
        end
    end
end
addCommandHandler("sync", handleCommand)

function handleSyncCommand(action, resname)
    if action == "refresh" or action == "refreshall" then
        refreshResources(action == "refreshall" and true or false)
    elseif action == "start" or action == "stop" or action == "restart" then
        local res = getResourceFromName(resname)
        if action == "start" then
            startResource(res, true)
        elseif action == "restart" then
            restartResource(res, true)
        else
            stopResource(res)
        end
    end
end

function handleGlobal(player, cmd, ...)
    local acc = getPlayerAccount(player)
    if not isGuestAccount(acc) and
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Developer")) or
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("Owner")) or
		isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("JRDev")) or
        isObjectInACLGroup("user." .. getAccountName(acc),
                           aclGetGroup("HeadAdmin")) or
        isObjectInACLGroup("user." .. getAccountName(acc), aclGetGroup("Admin")) then
        local myTable = {...}
        local myString = table.concat(myTable, " ")
        for k, v in ipairs(serversToSynchronize) do
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                       "handleGlobalCommand", function() end,
                       getPlayerName(player), myString)
        end
    end
end
addCommandHandler("g", handleGlobal)

function handleGlobalCommand(name, text)
    outputChatBox("#ff6464(Global) #ffffff" .. name .. "#ffffff: " .. text,
                  root, 255, 168, 0, true)
end

function addToStatsDatabase(serial, name, type)
    if type == "kills" then
        handleStreakCounter(serial, name)
    elseif type == "deaths" then
        resetStreak(serial)
    end
    keepStatsLive(serial, name, type, true)
    for k, v in ipairs(serversToSynchronize) do
        if v ~= tostring(getServerHttpPort()) then
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                       "keepStatsLive", function() end, serial, name, type,
                       false)
        end
    end
end

local roundStreak = {}

function handleStreakCounter(serial, name)
    if not roundStreak[serial] then
        roundStreak[serial] = 1
    else
        roundStreak[serial] = roundStreak[serial] + 1
    end
    if roundStreak[serial] >= 3 then
        outputChatBox("#[Killstreak] #878787"..name.." #ffffffhas a killstreak of #ff0000[x"..roundStreak[serial].."]", root, 255, 255, 255, true)
    end
end

-- addEvent("onGamemodeMapStart")
-- addEventHandler("onGamemodeMapStart", root, )

function resetStreak(serial)
    if serial then
        roundStreak[serial] = 0
    else
        roundStreak = {}
    end
end

addEventHandler("onPlayerQuit", root, function() resetStreak(getPlayerSerial(source)) end)

function keepStatsLive(serial, name, type, isLocal)
    if statsTable[serial] then
        statsTable[serial][type] = statsTable[serial][type] + 1
        statsTable[serial]["nickname"] = name
        if isLocal then
            dbExec(handle, "UPDATE `stats` SET `nickname`=?, `" .. type ..
                       "`=? WHERE `serial` = ?", name,
                   statsTable[serial][type] + 1, serial)
        end
    else
        statsTable[serial] = {
            nickname = name,
            kills = 0,
            deaths = 0,
            assists = 0,
            cws = 0
        }
        statsTable[serial][type] = 1
        if isLocal then
            dbExec(handle,
                   "INSERT INTO `stats` (`serial`, `nickname`, `kills`, `deaths`, `assists`, `cws`) VALUES (?, ?, ?, ?, ?, ?)",
                   serial, name, statsTable[serial]["kills"],
                   statsTable[serial]["deaths"], statsTable[serial]["assists"],
                   statsTable[serial]["cws"])
        end
    end
    updateSortedArray()
end

function round(num)
    local int, float = math.modf(num)
    if not float or float == 0 or float == "" then
        float = "0.0"
    end
    return int.."."..tostring(float):sub(3, 5)
  end

function updateSortedArray()
    local tableToSort = {}
    for k, v in pairs(statsTable) do
        if (v["cws"] > 4) then
            table.insert(tableToSort, {
                --kdr = round(tonumber(v["kills"])/(tonumber(v["deaths"]) ~= 0 and tonumber(v["deaths"]) or 1)),
                kdr = round((tonumber(v["kills"])+tonumber(v["assists"]))/(tonumber(v["deaths"]) ~= 0 and tonumber(v["deaths"]) or 1)),
                kills = v["kills"],
                deaths = v["deaths"],
                assists = v["assists"],
                nickname = v["nickname"],
                cws = v["cws"],
                serial = k
            })
        end
    end
    table.sort(tableToSort, function(a, b)
        return a.kdr > b.kdr
        --[[if a.kills ~= b.kills then
            return a.kills > b.kills
        elseif a.deaths ~= b.deaths then
            return a.deaths < b.deaths
        end
        return a.assists > b.assists]]
    end)
    for k, v in ipairs(tableToSort) do tableToSort[k].ranking = k end
    statsSorted = tableToSort
end

function sendStatsToPlayer()
    triggerClientEvent(client, "setGridlist", resourceRoot, statsSorted)
end
addEvent("onPlayerAskForStats", true)
addEventHandler("onPlayerAskForStats", resourceRoot, sendStatsToPlayer)

function handleRemoveCommand(player, cmd, serial)
    local account = getPlayerAccount(player)
    if (not isGuestAccount(account)) and
        (isObjectInACLGroup("user." .. getAccountName(account),
                            aclGetGroup("Owner")) or
            isObjectInACLGroup("user." .. getAccountName(account),
                               aclGetGroup("Developer"))) then
        if serial and serial ~= "" then
            if statsTable[serial] then
                removeStatsForSerial(serial, true)
                for k, v in ipairs(serversToSynchronize) do
                    if v ~= tostring(getServerHttpPort()) then
                        callRemote(serversIP .. ":" .. v, "default", 2, 1000,
                                   "ae-sync", "removeStatsForSerial",
                                   function() end, serial, false)
                    end
                end
                outputChatBox("Successfully removed this serial's stats!",
                              player)
            else
                outputChatBox("Couldn't find someone with this serial!", player)
            end
        else
            outputChatBox("You need to specify a serial to remove their stats!",
                          player)
        end
    end
end
addCommandHandler("removestats", handleRemoveCommand)

function removeStatsForSerial(serial, isLocal)
    if isLocal then
        dbExec(handle, "DELETE FROM `stats` WHERE `serial`=?", serial)
    end
    statsTable[serial] = nil
    updateSortedArray()
end

function getPlayers()
    local playersTable = {}
    for k, v in ipairs(getElementsByType('player')) do
        local kills, deaths, assists, kda
        if not statsTable[getPlayerSerial(v)] then
            kills, deaths, assists, kda = 0, 0, 0, 0
        else
            kills, deaths, assists = statsTable[getPlayerSerial(v)].kills, statsTable[getPlayerSerial(v)].deaths, statsTable[getPlayerSerial(v)].assists
            kda = round(tonumber(v["kills"])/(tonumber(v["deaths"]) ~= 0 and tonumber(v["deaths"]) or 1))
        end
        playersTable[k] = {name = getPlayerName(v):gsub("#%x%x%x%x%x%x"), kills = kills, deaths = deaths, assists = assists}
    end
    return playersTable
end

function getPlayersCount()
    return #getElementsByType('player')
end

function sendAdminChat(msg)
    for _, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( isPlayerOnGroup ( player ) ) then
            outputChatBox(msg, player, 255, 255, 255, true)
        end 
    end
end

function adminchat ( thePlayer, _, ... )
    local message = table.concat ( { ... }, " " )
    if ( isPlayerOnGroup ( thePlayer ) ) then
        local msgToSend = "#999910[StaffChat]#ffffff ".. getPlayerName(thePlayer) .."#ffffff: ".. message
        for k, v in ipairs(serversToSynchronize) do
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                    "sendAdminChat", function() end,
                    msgToSend)
        end
    end
end
addCommandHandler("a", adminchat)

function reportToTeam(player, _, ...)
    local reportMessage = table.concat ( { ... }, " " )
    if reportMessage and reportMessage ~= "" then
        local msgToSend = "#ff0000[REPORT]#ffffff "..getPlayerName(player).."#ffffff in Server #"..thisServer.." ["..reportMessage.."]"
        fetchRemote("http://"..serversIP..":5555", {method = "POST", formFields = {type = "report", message = msgToSend:gsub("#%x%x%x%x%x%x", "")}}, function() end)
        for k, v in ipairs(serversToSynchronize) do
            callRemote(serversIP .. ":" .. v, "default", 2, 1000, "ae-sync",
                    "sendAdminChat", function() end,
                    msgToSend)
        end
        outputChatBox("[REPORT]#ffffff Thank you, admins have been informed of your report.", player, 255, 0, 0, true)
    else
        outputChatBox("[REPORT]#ffffff You need to provide a reason for your report. /report reason", player, 255, 0, 0, true)
    end
end
addCommandHandler("report", reportToTeam)
 
function isPlayerOnGroup ( thePlayer )
    local account = getPlayerAccount ( thePlayer )
    local inGroup = false
    for _, group in ipairs ( {"Console", "Owner", "Co-Owner",  "Developer", "HeadAdmin", "Admin"} ) do  
        if isObjectInACLGroup ( "user.".. getAccountName ( account ), aclGetGroup ( group ) )   then
            inGroup = true
            break
        end
    end
 
    return inGroup
end

local icons = {"Owner", "Co-Owner",  "Developer", "JRDev", "HeadAdmin", "Admin", "HeadModerator", "Youtubers", "Friends", "EventWinner"}

function handleIconData(player)
    if player then
        local account = getPlayerAccount(player)
        if account and not isGuestAccount(account) then
            if isObjectInACLGroup("user."..getAccountName(account), aclGetGroup("Donator")) then
                setElementData(player, "isDonator", true)
            else
                setElementData(player, "isDonator", false)
            end
            for k, v in ipairs(icons) do
                local group = aclGetGroup(v)
                if group then
                    if isObjectInACLGroup("user."..getAccountName(account), group) then
                        return setElementData(player, "highestRole", v ~= "Co-Owner" and v or "Owner")
                    end
                end
            end
            return setElementData(player, "highestRole", false)
        end
    end
end