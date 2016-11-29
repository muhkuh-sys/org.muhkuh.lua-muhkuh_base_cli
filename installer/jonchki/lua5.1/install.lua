local t = ...

-- Copy the complete "lua" folder.
t:install('lua', '${install_lua_path}')

-- Copy the initialisation file to the base folder of the installation.
t:install('system/muhkuh_cli_init.lua', '${install_base}')

return true
