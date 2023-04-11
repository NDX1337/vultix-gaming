adminsList = {
    ["Owner"] = true,
	["Co-Owner"] = true,
	["Developer"] = true,
	["HeadAdmin"] = true,
	["JRDev"] = true,
	["Admin"] = true,
}

protectedList = {
	["Owner"] = true,
	["Co-Owner"] = true,
	["Developer"] = true,
	["HeadAdmin"] = true,
	["JRDev"] = true,
	["Admin"] = true,
}

function outputBan(ban, bannedBy)
	local playerName = getPlayerName(source)
	local account = getPlayerAccount(source)
	if account then
		local accountName = getAccountName(account)
		for name, _ in pairs(protectedList) do
			local groupName = aclGetGroup(name)
            if groupName then
                if isObjectInACLGroup("user." ..accountName, groupName) then
                    -- if (groupName == "Donator" or groupName == "Friends") and not isAdmin(bannedBy) then return end
                    -- if getElementType(protectedBan) == "player" then
                    -- 	banPlayer(protectedBan, true, false, true, source, groupName)
                    -- end
                    outputChatBox("#e60000[AntiBan] #FFFFFF" ..playerName.. " #ffffffhas not been banned", player, 255, 255, 255, true)
                    outputDebugString(playerName.. " has not been banned", 3)
                    removeBan(ban)
                    return
                end
            end
		end
	end
end
addEventHandler("onPlayerBan", root, outputBan)

function isAdmin(player)
    if isElement(player) then
        local account = getPlayerAccount(player)
        if account then
            local accountName = getAccountName(account)
            for name, _ in pairs(adminsList) do
                local groupName = aclGetGroup(name)
                if groupName then
                    if isObjectInACLGroup("user." ..accountName, groupName) then
                        return true
                    end
                end
            end
        end
    end
    return false
end