function specOnAFK (source)
	local name = getPlayerName(source)
	if (name:find("(S)", 1, true)) then
		setPlayerName(source, name:gsub("%(S%)", ""))
		outputChatBox("(S) tag has been removed from your nickname", source)
	elseif (name:find("(s)", 1, true)) then
		setPlayerName(source, name:gsub("%(s%)", ""))
		outputChatBox("(S) tag has been removed from your nickname", source)
	else
		local set = setPlayerName(source, name.."(S)")
		if not (set) then
			local nameLength = name:len()
			local needChars = 21-nameLength
			setPlayerName(source, string.sub(name, 1, -3+needChars).."(S)")
		end
		outputChatBox("(S) tag has been added to your nickname", source)
	end
end
addCommandHandler("afk", specOnAFK)