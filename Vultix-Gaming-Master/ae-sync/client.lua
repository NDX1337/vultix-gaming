function handleCommands(cmd, arg1, arg2)
    if cmd == "chgmypass" then
        if not arg1 or not arg2 then
            outputChatBox("chgmypass: Syntax is 'chgmypass <oldpass> <newpass>'", 255, 168, 0)
            return
        end
    elseif cmd ~= "authserial" then
        if not arg1 then
            return outputChatBox(cmd..": Syntax is '"..cmd.." [<nick>] <password>'", 255, 168, 0)
        elseif not arg2 then
            arg2 = arg1
            arg1 = getPlayerName(localPlayer)
        end
    end
    if cmd ~= "authserial" and #arg2 < 4 then
        outputChatBox(cmd..": - Password should be at least 4 characters long", 255, 100, 70)
        return
    end
    iprint("aeSync:onClientCustomCommand", resourceRoot, cmd, arg1, arg2)
    triggerServerEvent("aeSync:onClientCustomCommand", resourceRoot, cmd, arg1, arg2)
end
addCommandHandler("login", handleCommands)
addCommandHandler("register", handleCommands)
addCommandHandler("chgpass", handleCommands)
addCommandHandler("chgmypass", handleCommands)
addCommandHandler("authserial", handleCommands)
--addCommandHandler("addaccount", handleCommands) Disabled cuz not needed