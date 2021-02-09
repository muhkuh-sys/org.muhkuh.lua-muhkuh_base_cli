local class = require 'pl.class'
local TesterBase = require 'tester_base'
local TesterCli = class(TesterBase)


function TesterCli:_init(tLog)
  self:super()

  self.tLog = tLog
  self.fInteractivePluginSelection = false
end



function TesterCli:getCommonPlugin(strInterfacePattern, atPluginOptions)
  local tLog = self.tLog
  atPluginOptions = atPluginOptions or {}

  -- Is a plugin open?
  local tPlugin = self.tCommonPlugin
  local strPluginName = self.strCommonPluginName
  if tPlugin~=nil then
    -- Yes -> does it match the interface?
    local fMatches = false
    if strInterfacePattern==nil then
      -- An empty pattern matches all interfaces.
      fMatches = true
    elseif strInterfacePattern=='INTERACTIVE' then
      -- An interactive selection matches all interfaces.
      fMatches = true
    elseif string.match(strPluginName, strInterfacePattern)~=nil then
      fMatches = true
    end
    if fMatches~=true then
      -- The current plugin does not match the pattern.
      -- Close it and select a new one.
      self:closeCommonPlugin()
    end
  end

  if tPlugin==nil then
    if self.fInteractivePluginSelection==true or strInterfacePattern=='INTERACTIVE' then
      -- Ask the user to pick a plugin.
      -- NOTE: Do not limit the selection to the interface pattern. This is
      --       an override mode.

      local strInterface
      local iInterfaceIdx
      local aDetectedInterfaces

      repeat do
        -- Detect all interfaces.
        aDetectedInterfaces = {}
        for i,v in ipairs(__MUHKUH_PLUGINS) do
          tLog.debug('Detecting interfaces with plugin %s', v:GetID())
          local iDetected = v:DetectInterfaces(aDetectedInterfaces, atPluginOptions)
          tLog.debug('Found %d interfaces with plugin %s', iDetected, v:GetID())
        end
        tLog.debug('Found a total of %d interfaces with %d plugins', #aDetectedInterfaces, #__MUHKUH_PLUGINS)

        print('')
        -- Show all detected interfaces.
        if strInterfacePattern==nil then
          print('Please select the interface:')
        else
          print(string.format('Please select the interface for the pattern "%s":', strInterfacePattern))
        end
        for i,v in ipairs(aDetectedInterfaces) do
          print(string.format('%d: %s (%s) Used: %s, Valid: %s', i, v:GetName(), v:GetTyp(), tostring(v:IsUsed()), tostring(v:IsValid())))
        end
        print('R: rescan')
        print('C: cancel')

        -- Get the user input.
        repeat do
          io.write('>')
          strInterface = io.read():lower()
          iInterfaceIdx = tonumber(strInterface)
          -- Ask again until...
          --  1) the user requested a rescan ("r")
          --  2) the user canceled the selection ("c")
          --  3) the input is a number and it is an index to an entry in aDetectedInterfaces
        end until (strInterface=='r') or (strInterface=='c') or ((iInterfaceIdx~=nil) and (iInterfaceIdx>0) and (iInterfaceIdx<=#aDetectedInterfaces))
      -- Scan again if the user requested it.
      end until strInterface~='r'

      if strInterface~='c' then
        -- Create the plugin.
        local tInterface = aDetectedInterfaces[iInterfaceIdx]
        local strInterfaceName = tInterface:GetName()
        tPlugin = tInterface:Create()

        -- Connect the plugin.
        tPlugin:Connect()
        -- Use the plugin for further calls to this function.
        self.tCommonPlugin = tPlugin
        self.strCommonPluginName = strInterfaceName
      else
        tPlugin = nil
      end
    else
      -- Open a new plugin.

      -- Detect all interfaces.
      local aDetectedInterfaces = {}
      local atPlugins = _G.__MUHKUH_PLUGINS
      if atPlugins==nil then
        tLog.error('No plugins registered!')
      else
        for _, tPlugin in ipairs(atPlugins) do
          tPlugin:DetectInterfaces(aDetectedInterfaces, atPluginOptions)
        end
      end

      local iSelectedInterfaceIndex = nil
      if #aDetectedInterfaces==0 then
        tLog.error('No interface found.')
      else
        -- Search all detected interfaces for the pattern.
        if strInterfacePattern==nil then
          tLog.info('No interface pattern provided. Using the first interface.')
          iSelectedInterfaceIndex = 1
        else
          tLog.debug('Searching for an interface with the pattern "%s".', strInterfacePattern)
          for iInterfaceIdx, tInterface in ipairs(aDetectedInterfaces) do
            local strName = tInterface:GetName()
            if string.match(strName, strInterfacePattern)==nil then
              tLog.debug('Not connection to plugin "%s" as it does not match the interface pattern.', strName)
            else
              iSelectedInterfaceIndex = iInterfaceIdx
              break
            end
          end

          if iSelectedInterfaceIndex==nil then
            tLog.error('No interface matched the pattern "%s".', strInterfacePattern)
          end
        end
      end

      -- Found the interface?
      if iSelectedInterfaceIndex~=nil then
        local tInterface = aDetectedInterfaces[iSelectedInterfaceIndex]
        if tInterface==nil then
          tLog.error('The interface with the index %d does not exist.', iSelectedInterfaceIndex)
        else
          strInterfaceName = tInterface:GetName()
          tLog.info('Connecting to interface "%s".', strInterfaceName)

          tPlugin = tInterface:Create()
          tPlugin:Connect()
          if tPlugin==nil then
            tLog.error('Failed to connect to the interface "%s".', strInterfaceName)
          else
            self.tCommonPlugin = tPlugin
            self.strCommonPluginName = strInterfaceName
          end
        end
      end
    end
  end

  return tPlugin
end


return TesterCli
