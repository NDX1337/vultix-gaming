----------------- Anti-Bounce ----------------------
-- * The MIT License (MIT)
-- * 
-- * Copyright (c) 2016 Aleksi "Arezu" Lindeman and Jordy "Megadreams" Sleeubus
-- * 
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- * 
-- * The above copyright notice and this permission notice shall be included in all
-- * copies or substantial portions of the Software.
-- * 
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- * SOFTWARE.
---------------------------------------------------

--[[------------------
* We highly discourage
* directly editing the
* scripts. Please use
* the customization
* possibilities.
--------------------]]

----------------------
-- Variables
----------------------

Preferences = {}
Preferences = setmetatable({},{__index = Preferences})
Preferences.VERSION = 1

----------------------
-- Functions/Events
----------------------

function Preferences:loadPreferences()
	if(File.exists("@anti-bounce.xml")) then
		File.delete("@anti-bounce.xml")
	end
	
	if not (File.exists("@ab-settings.xml")) then
		Preferences:createPreferences()
	else
		local lSettingsXML = XML.load("@ab-settings.xml")
		local lSettingsNode = lSettingsXML:findChild("enabled",0)
		
		if(lSettingsNode:getValue() == "true") then
			Core.g_bABEnabled = true
		else
			Core.g_bABEnabled = false
		end
		
		lSettingsXML:destroy()
	end
	
	if(Core.g_SettingsTable["preferencemessage"]["disable"] == false) then
		if(Core.g_bABEnabled) then
			--outputChatBox(Core.g_SettingsTable["preferencemessage"]["value"]:gsub("%%1",Core.g_SettingsTable["enabledmessage"]["value"]),255,255,255,true)
		else
			--outputChatBox(Core.g_SettingsTable["preferencemessage"]["value"]:gsub("%%1",Core.g_SettingsTable["disabledmessage"]["value"]),255,255,255,true)
		end
	end
end

function Preferences:createPreferences()
	local lSettingsXML = XML.create("@ab-settings.xml","settings")
		
	local lVersionNode = lSettingsXML:createChild("version")
	lVersionNode:setValue(tostring(Preferences.VERSION))
	
	local lEnabledNode = lSettingsXML:createChild("enabled")
	lEnabledNode:setValue(tostring(Core.g_bABEnabled))
	
	lSettingsXML:saveFile()
	lSettingsXML:destroy()
end

function Preferences:updatePreferences()
	if not (File.exists("@ab-settings.xml")) then
		Preferences:createPreferences()
		return
	end
	
	local lSettingsXML = XML.load("@ab-settings.xml")
	local lSettingsNode = lSettingsXML:findChild("enabled",0)
	lSettingsNode:setValue(tostring(Core.g_bABEnabled))
	
	lSettingsXML:saveFile()
	lSettingsXML:destroy()
end

function Preferences:generateUniqueId()
	if(File.exists("uuid.json")) then
		local lSuccess,lRet = pcall(Preferences.readUniqueId)
		
		if(lSuccess) then
			return lRet
		end
		
		File.delete("uuid.json")
	end
	
	local lHash = md5(getPlayerSerial()..tostring(getTickCount() / math.random() * math.random(math.random(9999) * math.random(9999)))):lower()
	local lUUID = lHash:sub(0,8).."-"..lHash:sub(9,12).."-"..lHash:sub(13,16).."-"..lHash:sub(16,19).."-"..lHash:sub(20,31)
	
	local lFile = File.new("uuid.json")
	lFile:write(toJSON({["uuid"] = lUUID}))
	lFile:destroy()
	
	return lUUID
end

function Preferences.readUniqueId()
	local lFile = File.create("uuid.json")
	local lData = fromJSON(lFile:read(lFile:getSize()))
	lFile:destroy()
	
	return lData['uuid']
end