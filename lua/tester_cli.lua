
module("tester", package.seeall)

require("muhkuh")
require("select_plugin")


------------------------------
-- Globals for this module.
------------------------------

-- This is the plugin the user selected with the 'getCommonPlugin' function.
local m_commonPlugin = nil



function hexdump(strData, uiBytesPerRow)
	local uiCnt
	local uiByteCnt
	local aDump


	if not uiBytesPerRow then
		uiBytesPerRow = 16
	end

	uiByteCnt = 0
	for uiCnt=1,strData:len() do
		if uiByteCnt==0 then
			aDump = { string.format("%08X :", uiCnt-1) }
		end
		table.insert(aDump, string.format(" %02X", strData:byte(uiCnt)))
		uiByteCnt = uiByteCnt + 1
		if uiByteCnt==uiBytesPerRow then
			uiByteCnt = 0
			print(table.concat(aDump))
		end
	end
	if uiByteCnt~=0 then
		print(table.concat(aDump))
	end
end


function callback_progress(a,b)
	print(string.format("%d%% (%d/%d)", a*100/b, a, b))
	return true
end

function callback(a,b)
--	print(string.format("[netX %d] %s", b, a))
	io.write(a)
	return true
end



function stdRead(tParentWindow, tPlugin, ulAddress, sizData)
	return tPlugin:read_image(ulAddress, sizData, callback_progress, sizData)
end

function stdWrite(tParentWindow, tPlugin, ulAddress, strData)
	tPlugin:write_image(ulAddress, strData, callback_progress, string.len(strData))
end

function stdCall(tParentWindow, tPlugin, ulAddress, ulParameter)
	print("__/Output/____________________________________________________________________")
	tPlugin:call(ulAddress, ulParameter, callback, 0)
	print("")
	print("______________________________________________________________________________")
end


function getCommonPlugin(strPattern)
	local tPlugin


	-- Is a plugin open?
	if not m_commonPlugin then
		tPlugin = select_plugin.SelectPlugin(strPattern)
		if tPlugin then
			-- Connect the plugin.
			tPlugin:Connect()
			-- Use the plugin for further calls to this function.
			m_commonPlugin = tPlugin
		end
	end

	return m_commonPlugin
end


function closeCommonPlugin()
	if m_commonPlugin then
		if m_commonPlugin:IsConnected()==true then
			-- Disconnect the plugin.
			m_commonPlugin:Disconnect()
		end

		-- Free the plugin.
		if m_commonPlugin.delete~=nil then
			m_commonPlugin:delete()
		end
		m_commonPlugin = nil
	end
end




function getPanel()
	return 0
end


function mbin_open(strFilename, tPlugin)
	local strData
	local strMsg
	local aAttr


	-- Replace the ASIC_TYPE magic.
	if string.find(strFilename, "${ASIC_TYPE}")~=nil then
		-- Get the chip type.
		local tAsicTyp = tPlugin:GetChiptyp()
		local strAsic
		
		
		-- Get the binary for the ASIC.
		if tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX100 or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX500 then
			strAsic = "500"
		elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX50 then
			strAsic = "50"
		elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX10 then
			strAsic = "10"
		elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX56 or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX56B then
			strAsic = "56"
		else
			error("Unknown chiptyp!")
		end
		
		strFilename = string.gsub(strFilename, "${ASIC_TYPE}", strAsic)
	end
	
	-- Try to load the binary.
	strData, strMsg = muhkuh.load(strFilename)
	if not strData then
		error("Failed to load binary '" .. strFilename .. "': " .. strMsg)
	else
		-- Get the header from the binary.
		if string.sub(strData, 1, 4)~="mooh" then
			error("The file " .. strFilename .. " has no valid mooh header!")
		else
			aAttr = {}

			aAttr.strFilename = strFilename

			aAttr.ulHeaderVersionMaj = string.byte(strData,5) + string.byte(strData,6)*0x00000100
			aAttr.ulHeaderVersionMin = string.byte(strData,7) + string.byte(strData,8)*0x00000100
			aAttr.ulLoadAddress = string.byte(strData,9) + string.byte(strData,10)*0x00000100 + string.byte(strData,11)*0x00010000 + string.byte(strData,12)*0x01000000
			aAttr.ulExecAddress = string.byte(strData,13) + string.byte(strData,14)*0x00000100 + string.byte(strData,15)*0x00010000 + string.byte(strData,16)*0x01000000
			aAttr.ulParameterStartAddress = string.byte(strData,17) + string.byte(strData,18)*0x00000100 + string.byte(strData,19)*0x00010000 + string.byte(strData,20)*0x01000000
			aAttr.ulParameterEndAddress = string.byte(strData,21) + string.byte(strData,22)*0x00000100 + string.byte(strData,23)*0x00010000 + string.byte(strData,24)*0x01000000

			aAttr.strBinary = strData
		end
	end

	return aAttr
end


function mbin_debug(aAttr)
	print(string.format("file '%s':", aAttr.strFilename))
	print(string.format("\theader version: %d.%d", aAttr.ulHeaderVersionMaj, aAttr.ulHeaderVersionMin))
	print(string.format("\tload address:   0x%08x", aAttr.ulLoadAddress))
	print(string.format("\texec address:   0x%08x", aAttr.ulExecAddress))
	print(string.format("\tparameter:      0x%08x - 0x%08x", aAttr.ulParameterStartAddress, aAttr.ulParameterEndAddress))
	print(string.format("\tbinary:         %d bytes", aAttr.strBinary:len()))
end


function mbin_write(tParentWindow, tPlugin, aAttr)
	stdWrite(tParentWindow, tPlugin, aAttr.ulLoadAddress, aAttr.strBinary)
end


function mbin_set_parameter(tPlugin, aAttr, aParameter)
	if not aParameter then
		aParameter = 0
	end

	-- Write the standard header.
	tPlugin:write_data32(aAttr.ulParameterStartAddress+0x00, 0xFFFFFFFF)                          -- Init the test result.
	tPlugin:write_data32(aAttr.ulParameterStartAddress+0x08, 0x00000000)                          -- Reserved

	if type(aParameter)=="table" then
		tPlugin:write_data32(aAttr.ulParameterStartAddress+0x04, aAttr.ulParameterStartAddress+0x0c)  -- Address of test parameters.

		for iIdx,tValue in ipairs(aParameter) do
			if type(tValue)=="string" and tValue=="OUTPUT" then
				-- Initialize output variables with 0.
				ulValue = 0
			else
				ulValue = tonumber(tValue)
				if ulValue==nil then
					error(string.format("The parameter %s is no valid number.", tostring(tValue)))
				elseif ulValue<0 or ulValue>0xffffffff then
					error(string.format("The parameter %s exceeds the range of an unsigned 32bit integer number.", tostring(tValue)))
				end
			end
			tPlugin:write_data32(aAttr.ulParameterStartAddress+0x0c+((iIdx-1)*4), ulValue)
		end
	else
		-- One single parameter.
		tPlugin:write_data32(aAttr.ulParameterStartAddress+0x04, aParameter)
	end
end


function mbin_execute(tParentWindow, tPlugin, aAttr, aParameter, fnCallback, ulUserData)
	if not fnCallback then
		fnCallback = callback
	end
	if not ulUserData then
		ulUserData = 0
	end

	print("__/Output/____________________________________________________________________")
	tPlugin:call(aAttr.ulExecAddress, aAttr.ulParameterStartAddress, fnCallback, ulUserData)
	print("")
	print("______________________________________________________________________________")
	
	-- Read the result status.
	local ulResult = tPlugin:read_data32(aAttr.ulParameterStartAddress)
	if ulResult==0 then
		if type(aParameter)=="table" then
			-- Search the parameter for "OUTPUT" elements.
			for iIdx,tValue in ipairs(aParameter) do
				if type(tValue)=="string" and tValue=="OUTPUT" then
					-- This is an output element. Read the value from the netX memory.
					aParameter[iIdx] = tPlugin:read_data32(aAttr.ulParameterStartAddress+0x0c+((iIdx-1)*4))
				end
			end
		end
	end
	
	return ulResult
end


function mbin_simple_run(tParentWindow, tPlugin, strFilename, aParameter)
	local aAttr
	aAttr = mbin_open(strFilename, tPlugin)
	mbin_debug(aAttr)
	mbin_write(tParentWindow, tPlugin, aAttr)
	mbin_set_parameter(tPlugin, aAttr, aParameter)
	return mbin_execute(tParentWindow, tPlugin, aAttr, aParameter)
end

