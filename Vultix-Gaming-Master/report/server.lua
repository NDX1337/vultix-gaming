
addEvent("sendReportDiscord", true)
function sendReportDiscord(info)
local myWebhook = Webhook("https://discord.com/api/webhooks/876060510582353940/czZukmLuHTYkubxMADYM2Dzv2v3HNo4BJsZNPcQDkBzQf3EBJ0nzPX5KOJn26W4XSr7p", "Vultix Reports")
myWebhook = WHSetAvatar(
    myWebhook,
    "https://cdn.discordapp.com/attachments/850301179963375646/889872875337678848/logo.png"
)
myWebhook = WHSetEmbed(myWebhook, "")
myWebhook = WHESetDescription(myWebhook, "**Reason:** "..info.reason.."\n**Description:** "..info.description)
myWebhook = WHESetAuthor(myWebhook, "Reporting <"..info.pName..">",info.screenshot,"https://cdn.discordapp.com/attachments/850301179963375646/889872875337678848/logo.png")  
myWebhook = WHESetColor(myWebhook, "7372944")
myWebhook = WHESetField(myWebhook, "Players Involved:", info.others, true)
myWebhook = WHESetField(myWebhook, "SS URL:", info.screenshot, true)
myWebhook = WHESetFooter(myWebhook,"Posted by:  "..info.name:gsub( '#%x%x%x%x%x%x', '' ).." • "..info.serial,"")
--[[myWebhook = WHESetImage(
    myWebhook,
    "https://cdn.discordapp.com/attachments/762305935183970309/862654555447623730/d4d3bb5-82e062c3-2834-4ad5-8ecd-aa9f64a0fe4b.png"
)]]
WHSend(myWebhook, false)
end
addEventHandler("sendReportDiscord", root, sendReportDiscord)



function reportpanel(source, command)
local name = getPlayerName(source)
local serial = getPlayerSerial(source)
triggerClientEvent("reportPanel", source, serial, name)
end
addCommandHandler("creport", reportpanel)

