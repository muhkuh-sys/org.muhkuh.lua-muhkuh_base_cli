local class = require 'pl.class'
local TesterBase = class()


function TesterBase:_init()
  self.archive = require 'archive'
  self.json = require 'dkjson'
  self.pl = require'pl.import_into'()

  self.atCommonPlugin = {}
  self.astrCommonPluginName = {}

  self.tSocket = nil
  self.m_atSystemParameter = nil
end



function TesterBase:setSocket(tSocket)
  self.tSocket = tSocket
end



function TesterBase:getSystemParameter()
  return self.m_atSystemParameter
end



function TesterBase:setSystemParameter(atSystemParameter)
  self.m_atSystemParameter = atSystemParameter
end



function TesterBase:hexdump(strData, uiBytesPerRow)
  uiBytesPerRow = uiBytesPerRow or 16

  local aDump
  local uiByteCnt = 0
  local tLog = self.tLog
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



function TesterBase.callback_progress(a,b)
  print(string.format("%d%% (%d/%d)", math.floor(a*100/b), a, b))
  return true
end


function TesterBase.callback(a,b)
  io.write(a)
  return true
end



function TesterBase:stdRead(tPlugin, ulAddress, sizData)
  return tPlugin:read_image(ulAddress, sizData, self.callback_progress, sizData)
end



function TesterBase:stdWrite(tPlugin, ulAddress, strData)
  tPlugin:write_image(ulAddress, strData, self.callback_progress, string.len(strData))
end



function TesterBase:stdCall(tPlugin, ulAddress, ulParameter)
  print('__/Output/____________________________________________________________________')
  tPlugin:call(ulAddress, ulParameter, self.callback, 0)
  print('')
  print('______________________________________________________________________________')
end



function TesterBase:setCommonPlugin(tPlugin, uiIndex)
  -- Default to plugin index 0.
  uiIndex = uiIndex or 0

  self.atCommonPlugin[uiIndex] = tPlugin
  self.astrCommonPluginName[uiIndex] = tPlugin:GetName()
end



function TesterBase:closeCommonPlugin(uiIndex)
  -- Default to plugin index 0.
  uiIndex = uiIndex or 0

  local tPlugin = self.atCommonPlugin[uiIndex]
  if tPlugin~=nil and tPlugin:IsConnected()==true then
    -- Disconnect the plugin.
    tPlugin:Disconnect()
  end

  self.atCommonPlugin[uiIndex] = nil
  self.astrCommonPluginName[uiIndex] = nil
end



function TesterBase:mbin_open(strFilename, tPlugin)
  local aAttr


  -- Replace the ASIC_TYPE magic.
  if string.find(strFilename, "${ASIC_TYPE}")~=nil then
    -- Get the chip type.
    local tAsicTyp = tPlugin:GetChiptyp()

    -- Get the binary for the ASIC.
    local strAsic
    if tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX4000_RELAXED or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX4000_FULL or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NET4100_SMALL then
      strAsic = "4000"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX100 or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX500 then
      strAsic = "500"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX90_MPW then
      strAsic = "90_mpw"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX90 then
      strAsic = "90"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX90B then
      strAsic = "90b"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX56 or tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX56B then
      strAsic = "56"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX50 then
      strAsic = "50"
    elseif tAsicTyp==romloader.ROMLOADER_CHIPTYP_NETX10 then
      strAsic = "10"
    else
      error(string.format('Unknown chiptyp %s.', tostring(tAsicTyp)))
    end

    strFilename = string.gsub(strFilename, "${ASIC_TYPE}", strAsic)
  end

  -- Try to load the binary.
  local strData, strMsg = self.pl.utils.readfile(strFilename, true)
  if not strData then
    error(string.format('Failed to load the file "%s": %s', strFilename, strMsg))
  else
    -- Get the header from the binary.
    if string.sub(strData, 1, 4)~="mooh" then
      error(string.format('The file "%s" has no valid "mooh" header.', strFilename))
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


function TesterBase:mbin_debug(aAttr, tLogLevel)
  local tLog = self.tLog
  tLog.debug('file "%s":', aAttr.strFilename)
  tLog.debug('  header version: %d.%d', aAttr.ulHeaderVersionMaj, aAttr.ulHeaderVersionMin)
  tLog.debug('  load address:   0x%08x', aAttr.ulLoadAddress)
  tLog.debug('  exec address:   0x%08x', aAttr.ulExecAddress)
  tLog.debug('  parameter:      0x%08x - 0x%08x', aAttr.ulParameterStartAddress, aAttr.ulParameterEndAddress)
  tLog.debug('  binary:         %d bytes', aAttr.strBinary:len())
end


function TesterBase:mbin_write(tPlugin, aAttr)
  self:stdWrite(tPlugin, aAttr.ulLoadAddress, aAttr.strBinary)
end


function TesterBase:mbin_set_parameter(tPlugin, aAttr, aParameter)
  if not aParameter then
    aParameter = 0
  end

  -- Write the standard header.
  tPlugin:write_data32(aAttr.ulParameterStartAddress+0x00, 0xFFFFFFFF)                          -- Init the test result.
  tPlugin:write_data32(aAttr.ulParameterStartAddress+0x08, 0x00000000)                          -- Reserved

  if type(aParameter)=='table' then
    tPlugin:write_data32(aAttr.ulParameterStartAddress+0x04, aAttr.ulParameterStartAddress+0x0c)  -- Address of test parameters.

    for iIdx,tValue in ipairs(aParameter) do
      local ulValue
      if type(tValue)=='string' and tValue=='OUTPUT' then
        -- Initialize output variables with 0.
        ulValue = 0
      else
        ulValue = tonumber(tValue)
        if ulValue==nil then
          error(string.format('The parameter %s is no valid number.', tostring(tValue)))
        elseif ulValue<0 or ulValue>0xffffffff then
          error(string.format("The parameter %s exceeds the range of an unsigned 32bit integer number.", tostring(tValue)))
        end
      end
      local ulAddress = aAttr.ulParameterStartAddress + 0x0c + ((iIdx-1)*4)
      if ulAddress>aAttr.ulParameterEndAddress then
        error('The parameter exceed the available space.')
      end
      tPlugin:write_data32(ulAddress, ulValue)
    end
  elseif type(aParameter)=='string' then
    local ulEndAddress = aAttr.ulParameterStartAddress+0x0c+string.len(aParameter)
    if ulEndAddress>aAttr.ulParameterEndAddress then
      self.tLog.error('The parameter would use the area 0x%08x-0x%08x, but only 0x%08x-0x%08x is available.', aAttr.ulParameterStartAddress, ulEndAddress, aAttr.ulParameterStartAddress, aAttr.ulParameterEndAddress)
      error('The parameter exceed the available space.')
    end
    tPlugin:write_data32(aAttr.ulParameterStartAddress+0x04, aAttr.ulParameterStartAddress+0x0c)  -- Address of test parameters.
    self:stdWrite(tPlugin, aAttr.ulParameterStartAddress+0x0c, aParameter)
  else
    -- One single parameter.
    tPlugin:write_data32(aAttr.ulParameterStartAddress+0x04, aParameter)
  end
end


function TesterBase:mbin_execute(tPlugin, aAttr, aParameter, fnCallback, ulUserData)
  if not fnCallback then
    fnCallback = self.callback
  end
  if not ulUserData then
    ulUserData = 0
  end

  print('__/Output/____________________________________________________________________')
  tPlugin:call(aAttr.ulExecAddress, aAttr.ulParameterStartAddress, fnCallback, ulUserData)
  print('')
  print('______________________________________________________________________________')

  -- Read the result status.
  local ulResult = tPlugin:read_data32(aAttr.ulParameterStartAddress)
  if ulResult==0 then
    if type(aParameter)=='table' then
      -- Search the parameter for "OUTPUT" elements.
      for iIdx,tValue in ipairs(aParameter) do
        if type(tValue)=='string' and tValue=='OUTPUT' then
          -- This is an output element. Read the value from the netX memory.
          aParameter[iIdx] = tPlugin:read_data32(aAttr.ulParameterStartAddress+0x0c+((iIdx-1)*4))
        end
      end
    end
  end

  return ulResult
end


function TesterBase:mbin_simple_run(tPlugin, strFilename, aParameter,fnCallback)
	local aAttr = self:mbin_open(strFilename, tPlugin)
	self:mbin_debug(aAttr)
	self:mbin_write(tPlugin, aAttr)
	self:mbin_set_parameter(tPlugin, aAttr, aParameter)
	return self:mbin_execute(tPlugin, aAttr, aParameter, fnCallback)
end



function TesterBase:sendLogEvent(strEventId, atAttributes)
  local tSocket = self.tSocket
  if tSocket~=nil then
    local tData = { id=strEventId, attr=atAttributes }
    local strData = self.json.encode(tData)
    local strMsg = string.format('LEV%s', strData)
    tSocket:send(strMsg)
  end
end



function TesterBase:asciiArmor(strData)
  local archive = self.archive

  -- Create a new archive object.
  local tArchive = archive.ArchiveWrite()
  -- Output only the data from the filters.
  tArchive:set_format_raw()
  -- Filter the input data with GZIP and then BASE64.
  tArchive:add_filter_gzip()
  tArchive:add_filter_b64encode()
  -- Provide a buffer which is large enough for the compressed data.
  -- NOTE: 2 * the size of the input data is way to much.
  tArchive:open_memory(string.len(strData)*2)

  -- Now create a new archive entry - even if we do not have a real archive here.
  -- It is necessary to set the filetype of the entry to "regular file", or no
  -- data will arrive on the output side.
  local tEntry = archive.ArchiveEntry()
  tEntry:set_filetype(archive.AE_IFREG)
  -- First write the header, then the data, the finish the entry.
  tArchive:write_header(tEntry)
  tArchive:write_data(strData)
  tArchive:finish_entry()
  -- Write only one entry, as this is no real archive.
  tArchive:close()

  -- Get the compressed and encoded data.
  local strCompressed = tArchive:get_memory()

  return strCompressed
end



function TesterBase:updateSystemParameter(strKey, strValue)
  local atSystemParameter = self.m_atSystemParameter
  local tLog = self.tLog

  strKey = tostring(strKey)
  strValue = tostring(strValue)
  if atSystemParameter==nil then
    tLog.warning('No system parameter available, ignoring update [%s]="%s".', strKey, strValue)
  else
    tLog.debug('Set the system parameter [%s]="%s".', strKey, strValue)
    atSystemParameter[strKey] = strValue
  end
end


return TesterBase
