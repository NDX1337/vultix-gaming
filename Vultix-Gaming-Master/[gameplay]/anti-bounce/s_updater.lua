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

Updater = {}
Updater = setmetatable({},{__index = Updater})

----------------------
-- Functions/Events
----------------------

function Updater:setup()
	if(Settings.g_SettingsTable["checkupdates"]["value"] == false) then
		return
	end
	
	Updater:checkForUpdates()
	setTimer(Updater.checkForUpdates,Settings.g_SettingsTable["updatechecktimer"]["value"],0)
end

function Updater:checkForUpdates()
	if(Settings.g_SettingsTable["checkupdates"]["value"] == false) then
		return
	end
	
	fetchRemote("http://ultimateairgamers.com/mta/anti-bounce/update-info.txt", Updater.onUpdateInfoReceived, "", false)
end
