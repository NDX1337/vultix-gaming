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

Settings = {}
Settings = setmetatable({},{__index = Settings})

Settings.CONFIG_FILE = "config.xml"
Settings.g_KeyTable = {["mouse1"]= 0,["mouse2"]= 0,["mouse3"]= 0,["mouse4"]= 0,["mouse5"]= 0,["mouse_wheel_up"]= 0,["mouse_wheel_down"]= 0, 
["arrow_l"]= 0,["arrow_u"]= 0,["arrow_r"]= 0,["arrow_d"]= 0,["0"]= 0,["1"]= 0,["2"]= 0,["3"]= 0,["4"]= 0,["5"]= 0,["6"]= 0,["7"]= 0,["8"]= 0, 
["9"]= 0,["a"]= 0,["b"]= 0,["c"]= 0,["d"]= 0,["e"]= 0,["f"]= 0,["g"]= 0,["h"]= 0,["i"]= 0,["j"]= 0,["k"]= 0,["l"]= 0,["m"]= 0,["n"]= 0,["o"]= 0,
["p"]= 0,["q"]= 0,["r"]= 0,["s"]= 0,["t"]= 0,["u"]= 0,["v"]= 0,["w"]= 0,["x"]= 0,["y"]= 0,["z"]= 0,["num_0"]= 0,["num_1"]= 0,["num_2"]= 0,
["num_3"]= 0,["num_4"]= 0,["num_5"]= 0,["num_6"]= 0,["num_7"]= 0,["num_8"]= 0,["num_9"]= 0,["num_mul"]= 0,["num_add"]= 0,["num_sep"]= 0,
["num_sub"]= 0,["num_div"]= 0,["num_dec"]= 0,["num_enter"]= 0,["F1"]= 0,["F2"]= 0,["F3"]= 0,["F4"]= 0,["F5"]= 0,["F6"]= 0,
["F7"]= 0,["F8"]= 0,["F9"]= 0,["F10"]= 0,["F11"]= 0,["F12"]= 0,["escape"]= 0,["backspace"]= 0, ["tab"]= 0,["lalt"]= 0,["ralt"]= 0,["enter"]= 0,
["space"]= 0,["pgup"]= 0,["pgdn"]= 0,["end"]= 0,["home"]= 0,["insert"]= 0,["delete"]= 0,["lshift"]= 0,["rshift"]= 0, 
["lctrl"]= 0,["rctrl"]= 0,["["]= 0,["]"]= 0,["pause"]= 0,["capslock"]= 0,["scroll"]= 0,[";"]= 0,["]= 0,"]= 0,["-"]= 0,["."]= 0,["/"]= 0,
["#"]= 0,["\\"]= 0,["="]=0 }

--[[
Types:
0: boolean
1: number
2: string
]]

Settings.g_SettingsTable = {
	["enablecredits"] = {
		["value"] = false,
		["value_type"] = 0
	},
	["defaultstate"] = {
		["value"] = true,
		["value_type"] = 0
	},
	["infomessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff' or by simply pressing '#368DEB%2#ffffff'.",
		["value_type"] = 2,
		["disable"] = true,
		["disable_type"] = 0
	},
	["infomessage2"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffToggle the Anti-Bounce with '#368DEB%1#ffffff'.",
		["value_type"] = 2,
		["disable"] = true,
		["disable_type"] = 0
	},
	["togglemessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffThe Anti-Bounce is now %1#ffffff.",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["preferencemessage"] = {
		["value"] = "#3A85D6[Anti-Bounce]: #ffffffYour #368DEBpreferences #ffffffare #368DEBloaded #ffffff|| Anti-Bounce is %1#ffffff.",
		["value_type"] = 2,
		["disable"] = true,
		["disable_type"] = 0
	},
	["disabledmessage"] = {
		["value"] = "#ff0000disabled",
		["value_type"] = 2
	},
	["enabledmessage"] = {
		["value"] = "#00ff00enabled",
		["value_type"] = 2
	},
	["bouncecommands"] = {
		["value"] = "ab",
		["value_type"] = 2,
		["disable"] = false,
		["disable_type"] = 0
	},
	["bouncebind"] = {
		["value"] = "f10",
		["value_type"] = 2,
		["disable"] = true,
		["disable_type"] = 0
	},
	["checkupdates"] = {
		["value"] = true,
		["value_type"] = 0,
	},
	["updatechecktimer"] = {
		["value"] = 1800000,
		["value_type"] = 1,
	},
	["enablestats"] = {
		["value"] = true,
		["value_type"] = 0,
		["removed"] = true
	},
	["enablesettingstats"] = {
		["value"] = true,
		["value_type"] = 0,
		["removed"] = true
	},
	["enableplayerstats"] = {
		["value"] = true,
		["value_type"] = 0,
		["removed"] = true
	},
}

----------------------
-- Functions/Events
----------------------

function Settings:loadSettings()
	if not File.exists(Settings.CONFIG_FILE) then
		Settings:createConfigurationFile()
		return
	end
	
	local lConfigXML = XML.load(Settings.CONFIG_FILE)
	if(lConfigXML == false) then
		Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to read the configuration file.",255,255,255,true)
		return
	end
	
	for _,lNode in pairs(lConfigXML:getChildren()) do
		local lNodeName = lNode:getName()
		
		if(Settings.g_SettingsTable[lNodeName] ~= nil) then
			if(Settings.g_SettingsTable[lNodeName]["value"] ~= nil) then
				if(Settings.g_SettingsTable[lNodeName]["removed"]) then
					outputDebugString("[Anti-Bounce]: Setting '"..lNodeName.."' has been removed. Please remove it from your configuration.",0,58,133,214)
				end
				
				local lValue = lNode:getValue()
				
				if(lValue ~= false and lValue ~= "") then
					if(Settings.g_SettingsTable[lNodeName]["value_type"] == 0) then
						if(lValue == "true") then
							Settings.g_SettingsTable[lNodeName]["value"] = true
						elseif(lValue == "false") then
							Settings.g_SettingsTable[lNodeName]["value"] = false
						else
							Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
								.."boolean (true/false) as value. Please modify it.",255,255,255,true)
						end
					elseif(Settings.g_SettingsTable[lNodeName]["value_type"] == 1) then
						if(tonumber(lValue) ~= nil) then
							Settings.g_SettingsTable[lNodeName]["value"] = tonumber(lValue)
						else
							Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
								.."number as value. Please modify it.",255,255,255,true)
						end
					elseif(Settings.g_SettingsTable[lNodeName]["value_type"] == 2) then
						Settings.g_SettingsTable[lNodeName]["value"] = lValue
					end
				else
					Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffff"..tostring(lNodeName).." #ff0000expects a "
						.."value. Please add it.",255,255,255,true)
				end
			end
			
			for lName,lValue in pairs(lNode:getAttributes()) do
				if(Settings.g_SettingsTable[lNodeName][lName] ~= nil) then
					if(lValue ~= false and lValue ~= "") then
						if(Settings.g_SettingsTable[lNodeName][lName.."_type"] == 0) then
							if(lValue == "true") then
								Settings.g_SettingsTable[lNodeName][lName] = true
							elseif(lValue == "false") then
								Settings.g_SettingsTable[lNodeName][lName] = false
							else
								Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The attribute #ffffff"..lName.." #ff0000in setting #ffffff"
									..tostring(lNodeName).." #ff0000expects a boolean (true/false) as value. Please modify it.",255,255,255,true)
							end
						elseif(Settings.g_SettingsTable[lNodeName][lName.."_type"] == 1) then
							if(tonumber(lValue) ~= nil) then
								Settings.g_SettingsTable[lNodeName][lName] = tonumber(lValue)
							else
								Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The attribute #ffffff"..lName.." #ff0000in setting #ffffff"
									..tostring(lNodeName).." #ff0000expects a number as value. Please modify it.",255,255,255,true)
							end
						elseif(Settings.g_SettingsTable[lNodeName][lName.."_type"] == 2) then
							Settings.g_SettingsTable[lNodeName][lName] = lValue
						end
					else
						Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The attribute #ffffff"..lName.." #ff0000in setting #ffffff"
							..tostring(lNodeName).." #ff0000expects a value. Please add it.",255,255,255,true)
					end
				else
					Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffff"..tostring(lNodeName).." #ff0000doesnt have a attribute "
						.."#ffffff"..tostring(lName)..". #ff0000Please remove it.",255,255,255,true)
				end
			end
		else
			Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffff"..tostring(lNodeName).." #ff0000in the configuration file "
			.."is not a supported setting.",255,255,255,true)
		end
	end
	
	if(Settings.g_SettingsTable["bouncebind"]["disable"] == false) then
		if(Settings.g_KeyTable[Settings.g_SettingsTable["bouncebind"]["value"]] == nil and
			Settings.g_KeyTable[Settings.g_SettingsTable["bouncebind"]["value"]:upper()] == nil) then
			Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000The setting #ffffffbouncebind #ff0000has an invalid key to " 
				.."bind on. Please modify it.",255,255,255,true)
				Settings.g_SettingsTable["bouncebind"]["disable"] = true
		end
	end
	
	lConfigXML:destroy()
end

function Settings:createConfigurationFile()
	local lConfigFile = File.new(Settings.CONFIG_FILE)
	if(lConfigFile == false) then
		Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ff0000Unable to create a configuration file.",255,255,255,true)
		return
	end
	
	lConfigFile:write(
[[<config>
	<!-- 
		 Do you want to show a little message in the chat telling everyone whose hard work creating the Anti-Bounce was?
		 true = enabled, false = disabled, Default: ]]..tostring(Settings.g_SettingsTable["enablecredits"]["value"])..[[ 
	-->
	<enablecredits>]]..tostring(Settings.g_SettingsTable["enablecredits"]["value"])..[[</enablecredits>
	
	<!-- 
		 What state the Anti-Bounce has to be at default for new players?
		 true = enabled, false = disabled, Default: ]]..tostring(Settings.g_SettingsTable["defaultstate"]["value"])..[[ 
	-->
	<defaultstate>]]..tostring(Settings.g_SettingsTable["defaultstate"]["value"])..[[</defaultstate>
	
	<!-- 
		 This message is shown when both commands as binds are set. Use %1 where the commands have to be shown and %2 where 
		 the bind has to be shown.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["infomessage"]["value"])..[[
		 
		 Attributes: disable (Disables the message when set to true. Default: ]]..tostring(Settings.g_SettingsTable["infomessage"]["disable"])..[[)
	-->
	<infomessage disable="]]..tostring(Settings.g_SettingsTable["infomessage"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["infomessage"]["value"])..[[</infomessage>
	
	<!-- 
		 This message is shown when either only the commands are enabled or a bind is set. Use %1 on the place they have to be shown.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["infomessage2"]["value"])..[[
		 
		 Attributes: disable (Disables the message when set to true. Default: ]]..tostring(Settings.g_SettingsTable["infomessage2"]["disable"])..[[)
	-->
	<infomessage2 disable="]]..tostring(Settings.g_SettingsTable["infomessage2"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["infomessage2"]["value"])..[[</infomessage2>
	
	<!-- 
		 This message is shown whenever the Anti-Bounce is turned on/off. Use %1 wherever it should be replaced with either "disabled" or "enabled".
		 Those are both also customizable under "disabledmessage" and "enabledmessage".
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["togglemessage"]["value"])..[[
		 
		 Attributes: disable (Disables the message when set to true. Default: ]]..tostring(Settings.g_SettingsTable["togglemessage"]["disable"])..[[)
	-->
	<togglemessage disable="]]..tostring(Settings.g_SettingsTable["togglemessage"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["togglemessage"]["value"])..[[</togglemessage>
	
	<!-- 
		 This message is shown when the player' preferences are loaded. Use %1 wherever the state should be replaced with either "disabled" or 
		 "enabled". Those are both also customizable under "disabledmessage" and "enabledmessage".
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["preferencemessage"]["value"])..[[
		 
		 Attributes: disable (Disables the message when set to true. Default: ]]..tostring(Settings.g_SettingsTable["preferencemessage"]["disable"])..[[)
	-->
	<preferencemessage disable="]]..tostring(Settings.g_SettingsTable["preferencemessage"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["preferencemessage"]["value"])..[[</preferencemessage>
	
	<!-- 
		 This message is used in togglemessage and preferencemessage to show that the Anti-Bounce is disabled.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["disabledmessage"]["value"])..[[
	
	-->
	<disabledmessage>]]..tostring(Settings.g_SettingsTable["disabledmessage"]["value"])..[[</disabledmessage>
	
	<!-- 
		 This message is used in togglemessage and preferencemessage to show that the Anti-Bounce is enabled.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["enabledmessage"]["value"])..[[
	
	-->
	<enabledmessage>]]..tostring(Settings.g_SettingsTable["enabledmessage"]["value"])..[[</enabledmessage>
	
	<!-- 
		 You are able to specify what commands (separate each command with "," you want your players to be able to use to
		 toggle the Anti-Bounce with.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["bouncecommands"]["value"])..[[
		 
		 Attributes: disable (Disables the use of commands when set to true. Default: ]]..tostring(Settings.g_SettingsTable["bouncecommands"]["disable"])..[[)
	-->
	<bouncecommands disable="]]..tostring(Settings.g_SettingsTable["bouncecommands"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["bouncecommands"]["value"])..[[</bouncecommands>
	
	<!-- 
		 You are able to specify what key to set to bind the toggle feature of the Anti-Bounce can be used with.
		 
		 Value: String, 
		 Default: ]]..tostring(Settings.g_SettingsTable["bouncebind"]["value"])..[[
		 
		 Attributes: disable (Disables the use of a bind when set to true. Default: ]]..tostring(Settings.g_SettingsTable["bouncebind"]["disable"])..[[)
	-->
	<bouncebind disable="]]..tostring(Settings.g_SettingsTable["bouncebind"]["disable"])..[[">]]..tostring(Settings.g_SettingsTable["bouncebind"]["value"])..[[</bouncebind>
	
	<!-- 
		 Should the Anti-Bounce script check for updates and inform you about them?
		 
		 true = yes, false = no, Default: ]]..tostring(Settings.g_SettingsTable["checkupdates"]["value"])..[[ 
	-->
	<checkupdates>]]..tostring(Settings.g_SettingsTable["checkupdates"]["value"])..[[</checkupdates>
	
	<!-- 
		Here you are able to specify after what interval (in milliseconds) the script should check for updates. This requires
		checkupdates to be set on true.
		 
		Default: ]]..tostring(Settings.g_SettingsTable["updatechecktimer"]["value"])..[[ 
	-->
	<updatechecktimer>]]..tostring(Settings.g_SettingsTable["updatechecktimer"]["value"])..[[</updatechecktimer>
</config>]])
	
	lConfigFile:close()

	Utils:outputMessageToAdmins("#3A85D6[Anti-Bounce]: #ffffffA new configuration file has been created. In case you want to "
		.."customize the script you might consider editing it.",255,255,255,true)
end

function Settings:onSettingsRequest()
	triggerClientEvent(client,"onSettingsReceived",Core.g_ResourceRoot,Settings.g_SettingsTable)
end
addEvent("onSettingsRequest",true)
addEventHandler("onSettingsRequest",Core.g_ResourceRoot,Settings.onSettingsRequest)