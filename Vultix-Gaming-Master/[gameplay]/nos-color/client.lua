addEventHandler("onClientResourceStart",resourceRoot,
function()
	nitroShader = dxCreateShader("nos.fx")
	loadNosConfig()
end)

function updateNitroColor(r,g,b)
	if nitroShader then
		if r and g and b then
			engineApplyShaderToWorldTexture (nitroShader,"smoke")
			dxSetShaderValue (nitroShader, "gNitroColor", r/255, g/255, b/255 )
		end
	end
end

function resetNitroColor()
	if nitroShader then
		engineRemoveShaderFromWorldTexture(nitroShader,"smoke")
		local xml = xmlLoadFile("conf.xml")
		if xml then
			xmlNodeSetAttribute(xml,"r","NAN")
			xmlNodeSetAttribute(xml,"g","NAN")
			xmlNodeSetAttribute(xml,"b","NaN")
		end
		xmlSaveFile(xml)
		xmlUnloadFile(xml)	
	end
end


-- Basic util to convert HEX to RGB
function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- Saving nos RGB values to xml
function saveNosConfig(r,g,b)
	local xml = xmlLoadFile("conf.xml")
	if not xml then
		xml = xmlCreateFile("conf.xml","config")
		xmlNodeSetAttribute(xml,"r",r)
		xmlNodeSetAttribute(xml,"g",g)
		xmlNodeSetAttribute(xml,"b",b)
	else
		xmlNodeSetAttribute(xml,"r",r)
		xmlNodeSetAttribute(xml,"g",g)
		xmlNodeSetAttribute(xml,"b",b)
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end


-- Getting nos RGB values from xml
function loadNosConfig()
	local xml = xmlLoadFile("conf.xml")
	if xml then
		local r = xmlNodeGetAttribute(xml,"r")
		local g = xmlNodeGetAttribute(xml,"g")
		local b = xmlNodeGetAttribute(xml,"b")
		if r == "NAN" then 
		else
			updateNitroColor(r,g,b)
		end
	end
	xmlUnloadFile(xml)	
end

-- /nos ffaabb 
-- example usage of command
addCommandHandler("noscolor",
function(command,hexString)
	if hexString then
		local r,g,b = hex2rgb(hexString)
		if r <= 255 and g <= 255 and b <= 255 then
			updateNitroColor(r,g,b)
			saveNosConfig(r,g,b)
			outputChatBox("Nitro color updated!",255,255,255,true)
		end
	else
		resetNitroColor()
		outputChatBox("Nitro color reset to original!",255,255,255,true)
	end
end)
