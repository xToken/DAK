//DAKLoader SV Commands

//******************************************************************************************************************
//Extra Server Admin commands
//******************************************************************************************************************

local function OnCommandRCON(client, ...)

	 local rconcommand = StringConcatArgs(...)
	 if rconcommand ~= nil and client ~= nil then
		Shared.Message(string.format("%s executed command %s.", client:GetUserId(), rconcommand))
		Shared.ConsoleCommand(rconcommand)
		ServerAdminPrint(client, string.format("Command %s executed.", rconcommand))
		if client ~= nil then 
			local player = client:GetControllingPlayer()
			if player ~= nil then
				PrintToAllAdmins("sv_rcon", client, " " .. rconcommand)
			end
		end
	end

end

DAKCreateServerAdminCommand("Console_sv_rcon", OnCommandRCON, "<command>, Will execute specified command on server.")

local function OnCommandListPlugins(client)

	if client ~= nil and kDAKConfig then
		for k,v in pairs(kDAKConfig) do
			local plugin = k
			local version = kDAKRevisions[plugin]
			if version == nil then version = 1 end
			if plugin ~= nil then
				if v.kEnabled then
					ServerAdminPrint(client, string.format("Plugin %s v%.1f is enabled.", plugin, version))
					//Shared.Message(string.format("Plugin %s v%.1f is enabled.", plugin, version))
				else
					ServerAdminPrint(client, string.format("Plugin %s is disabled.", plugin))
					//Shared.Message(string.format("Plugin %s is disabled.", plugin))
				end
			end
		end
	end

end

DAKCreateServerAdminCommand("Console_sv_listplugins", OnCommandListPlugins, "Will list the state of all plugins.")	

local function OnCommandListMap(client)
	local matchingFiles = { }
	Shared.GetMatchingFileNames("maps/*.level", false, matchingFiles)

	for _, mapFile in pairs(matchingFiles) do
		local _, _, filename = string.find(mapFile, "maps/(.*).level")
		if client ~= nil then
			ServerAdminPrint(client, string.format(filename))
		end		
	end
end

DAKCreateServerAdminCommand("Console_sv_maps", OnCommandListMap, "Will list all the maps currently on the server.")

local function OnCommandCheats(client, parm)
	local num = tonumber(parm)
	if client ~= nil and num ~= nil then
		ServerAdminPrint(client, string.format("Command sv_cheats %s executed.", parm))
		Shared.ConsoleCommand("cheats " .. parm)
		local player = client:GetControllingPlayer()
		if player ~= nil then
			PrintToAllAdmins("sv_cheats", client, " " .. parm)
		end
	end
end

DAKCreateServerAdminCommand("Console_sv_cheats", OnCommandCheats, "<1/0> Will enable/disable cheats.")

local function OnCommandKillServer(client)
	if client ~= nil then 
		ServerAdminPrint(client, string.format("Command sv_killserver executed."))
		local player = client:GetControllingPlayer()
		if player ~= nil then
			PrintToAllAdmins("sv_killserver", client)
		end
	end
	//No need for this durrrrr, server supports exit
	//Shared.ConsoleCommand("exit") I wish :<
	CRASHFILE = io.open("config://CRASHFILE", "w")
	if CRASHFILE then
		CRASHFILE:seek("end")
		CRASHFILE:write("\n CRASH")
		CRASHFILE:close()
	end
end

DAKCreateServerAdminCommand("Console_sv_killserver", OnCommandKillServer, "Will crash the server (lol).")

//Load Plugins
local function LoadPlugins()
	if kDAKConfig == nil or kDAKConfig == { } or kDAKConfig.DAKLoader == nil or kDAKConfig.DAKLoader == { } or kDAKConfig.DAKLoader.kPluginsList == nil then
		DAKGenerateDefaultDAKConfig(true)
	end
	if kDAKConfig ~= nil and kDAKConfig.DAKLoader ~= nil  then
		for i = 1, #kDAKConfig.DAKLoader.kPluginsList do
			local filename = string.format("lua/plugins/plugin_%s.lua", kDAKConfig.DAKLoader.kPluginsList[i])
			Script.Load(filename)
		end
	else
		Shared.Message("Something may be wrong with your config file.")
	end
end

LoadPlugins()

DAKCreateServerAdminCommand("Console_sv_reloadplugins", LoadPlugins, "Reloads all plugins.")