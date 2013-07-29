//DAKloader SV Commands

//******************************************************************************************************************
//Extra Server Admin commands
//******************************************************************************************************************

local function OnCommandRCON(client, ...)

	 local rconcommand = StringConcatArgs(...)
	 if rconcommand ~= nil and client ~= nil then
		//Shared.Message(string.format("%s executed command %s.", client:GetUserId(), rconcommand))
		Shared.ConsoleCommand(rconcommand)
		ServerAdminPrint(client, string.format("Command %s executed.", rconcommand))
		DAK:PrintToAllAdmins("sv_rcon", client, " " .. rconcommand)
	end

end

DAK:CreateServerAdminCommand("Console_sv_rcon", OnCommandRCON, "<command> Will execute specified command on server.")

local function OnCommandAllTalk(client)

	if DAK.settings then
		DAK.settings.AllTalk = not DAK.settings.AllTalk
	else
		DAK.settings = { }
		DAK.settings.AllTalk = true
	end
	
	ServerAdminPrint(client, string.format("AllTalk has been %s.", ConditionalValue(DAK.settings.AllTalk,"enabled", "disabled")))
	DAK:PrintToAllAdmins("sv_alltalk", client)

end

DAK:CreateServerAdminCommand("Console_sv_alltalk", OnCommandAllTalk, "Will toggle the alltalk setting on server.")

local function OnCommandFriendlyFire(client)

	if DAK.settings then
		DAK.settings.FriendlyFire = not DAK.settings.FriendlyFire
	else
		DAK.settings = { }
		DAK.settings.FriendlyFire = true
	end
	
	ServerAdminPrint(client, string.format("FriendlyFire has been %s.", ConditionalValue(DAK.settings.FriendlyFire,"enabled", "disabled")))
	DAK:PrintToAllAdmins("sv_friendlyfire", client)

end

DAK:CreateServerAdminCommand("Console_sv_friendlyfire", OnCommandFriendlyFire, "Will toggle friendlyfire setting on server.")

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

DAK:CreateServerAdminCommand("Console_sv_maps", OnCommandListMap, "Will list all the maps currently on the server.")

local function OnCommandKillServer(client)

	ServerAdminPrint(client, string.format("Command sv_killserver executed."))
	DAK:PrintToAllAdmins("sv_killserver", client)
	
	//They finally fixed seek crash bug :<
	Server.GetClientAddress(nil)
	//Alriiight found a new crash bug
end

DAK:CreateServerAdminCommand("Console_sv_killserver", OnCommandKillServer, "Will crash the server (lol).")

local function OnCommandListAdmins(client)

	if DAK.adminsettings ~= nil then
		if DAK.adminsettings.groups ~= nil then
			for group, commands in pairs(DAK.adminsettings.groups) do
				ServerAdminPrint(client, string.format(group .. " - " .. ToString(commands)))
			end
		end

		if DAK.adminsettings.users ~= nil then
			for name, user in pairs(DAK.adminsettings.users) do
				local online = DAK:GetClientMatchingNS2Id(user.id) ~= nil
				ServerAdminPrint(client, string.format(name .. " - " .. ToString(user) .. ConditionalValue(online, " - Online", " - Offline")))
			end
		end
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_listadmins", OnCommandListAdmins, "Will list all groups and admins.")

local function ListBans(client)

	ServerAdminPrint(client, "Current Bans Listing:")
	for id, entry in pairs(DAK.bannedplayers) do
	
		local timeLeft = entry.time == 0 and "Forever" or (((entry.time - Shared.GetSystemTime()) / 60) .. " minutes")
		ServerAdminPrint(client, "Name: " .. entry.name .. " Id: " .. id .. " Time Remaining: " .. timeLeft .. " Reason: " .. (entry.reason or "Not provided"))
		
	end
	
	if DAK.bannedplayersweb ~= nil then
		for id, entry in pairs(DAK.bannedplayersweb) do
		
			local timeLeft = entry.time == 0 and "Forever" or (((entry.time - Shared.GetSystemTime()) / 60) .. " minutes")
			ServerAdminPrint(client, "Name: " .. entry.name .. " Id: " .. id .. " Time Remaining: " .. timeLeft .. " Reason: " .. (entry.reason or "Not provided"))
			
		end
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_listbans", ListBans, "Lists the banned players")

local function OnCommandWho(client)

	local onlineusers = false
	if DAK.adminsettings ~= nil then
		if DAK.adminsettings.users ~= nil then
			for name, user in pairs(DAK.adminsettings.users) do
				local uclient = DAK:GetClientMatchingNS2Id(user.id)
				local online = (uclient ~= nil)
				if online then
					local player = uclient:GetControllingPlayer()
					if player ~= nil then
						local pname = player:GetName()
						ServerAdminPrint(client, string.format(pname .. " - " .. name .. " - " .. ToString(user)))
						onlineusers = true
					end	
				end
			end
		end
	end
	if not onlineusers then
		ServerAdminPrint(client, string.format("No admins online."))
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_who", OnCommandWho, "Will list all online admins.", true)

local function PrintHelpForCommand(client, optionalCommand)

	for c = 1, #DAK.serveradmincommands do
	
		local command = DAK.serveradmincommands[c]
		if optionalCommand == command.name or optionalCommand == nil then
		
			if not client or DAK:GetClientCanRunCommand(client, command.name, false) or command.alwaysallowed then
				ServerAdminPrint(client, command.name .. ": " .. command.help)
			elseif optionalCommand then
				ServerAdminPrint(client, "You do not have access to " .. optionalCommand)
			end
			
		end
		
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_help", PrintHelpForCommand, "Prints help for all commands or the specified command.", true)