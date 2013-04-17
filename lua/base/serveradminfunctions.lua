//Global Group related functions
function DAK:GetGroupCanRunCommand(groupName, commandName)

	local group = DAK.adminsettings.groups[groupName]
	if not group then
		Shared.Message("Invalid groupname defined : " .. groupName)
		return false
	end
	
	local existsInList = false
	for c = 1, #group.commands do
	
		if group.commands[c] == commandName then
		
			existsInList = true
			break
			
		end
		
	end
	
	if group.type == "allowed" then
		return existsInList
	elseif group.type == "disallowed" then
		return not existsInList
	else
		Shared.Message(string.format("Invalid grouptype - %s defined on group - %s.", tostring(group.type), groupName))
		return false
	end
	
end

function DAK:GetClientCanRunCommand(client, commandName)

	//ServerConsole can run anything
	if client == nil then return true end
	// Convert to the old Steam Id format.
	local ns2id = client:GetUserId()
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == ns2id then
		
			for g = 1, #user.groups do
			
				local groupName = user.groups[g]
				if DAK:GetGroupCanRunCommand(groupName, commandName) then
					return true
				end
				
			end
			
		end
		
	end

	return false
	
end

function DAK:GetClientIsInGroup(client, gpName)
	local ns2id = client:GetUserId()
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == ns2id then
			for g = 1, #user.groups do
				local groupName = user.groups[g]
				if groupName == gpName then
					return true
				end
			end
		end
    end
end
	
function DAK:AddSteamIDToGroup(ns2id, groupNameToAdd)
	for name, user in pairs(DAK.adminsettings.users) do
		if user.id == ns2id then
			for g = 1, #user.groups do
				if user.groups[g] == groupNameToAdd then
					groupNameToAdd = nil
				end
			end
			if groupNameToAdd ~= nil then
				table.insert(user.groups, groupNameToAdd)
			end
			break
		end
	end
end

function DAK:RemoveSteamIDFromGroup(ns2id, groupNameToRemove)
	for name, user in pairs(DAK.adminsettings.users) do
		if user.id == ns2id then
			for r = #user.groups, 1, -1 do
				if user.groups[r] ~= nil then
					if user.groups[r] == groupNameToRemove then
						table.remove(user.groups, r)
					end
				end
			end
		end
	end
end

//Client Level checking
local function GetNS2IDLevel(ns2id)

	local level = 0
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == ns2id then
			if user.level ~= nil then
				level = user.level
			else
				for g = 1, #user.groups do
					local groupName = user.groups[g]
					local group = DAK.adminsettings.groups[groupName]
					if group and group.level ~= nil and group.level > level then
						level = group.level							
					end
				end
			end
		end
	end
	if tonumber(level) == nil then
		level = 0
	end
	
	return level
end

local function GetClientLevel(client)
	local ns2id = client:GetUserId()
	if ns2id == nil then return 0 end
	return GetNS2IDLevel(ns2id)
end

local function GetPlayerLevel(player)
	local client = Server.GetOwner(player)
	if client == nil then return 0 end
	local ns2id = client:GetUserId()
	if ns2id == nil then return 0 end
	return GetNS2IDLevel(ns2id)
end

local function GetObjectLevel(target)
	if tonumber(target) ~= nil then
		return GetNS2IDLevel(tonumber(target))
	elseif DAK:VerifyClient(target) ~= nil then
		return GetClientLevel(target)
	elseif Server.GetOwner(target) ~= nil then
		return GetPlayerLevel(target)
	end
	return 0
end

local function EmptyServerAdminCommand()
end

function DAK:GetLevelSufficient(client, targetclient)
	if client == nil then return true end
	if targetclient == nil then return false end
	return GetObjectLevel(client) >= GetObjectLevel(targetclient)
end

function DAK:GetServerAdminFunction(commandName)
	return DAK.serveradmincommandsfunctions[commandName]
end

function DAK:DeregisterServerAdminCommand(commandName)
	DAK.serveradmincommandsfunctions[commandName] = EmptyServerAdminCommand
end

local function CreateBaseServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)

	local fixedCommandName = string.gsub(commandName, "Console_", "")
	DAK.serveradmincommandsfunctions[commandName] = function(client, ...)
	
		if not client or optionalAlwaysAllowed == true or DAK:GetClientCanRunCommand(client, fixedCommandName, true) then
			return commandFunction(client, ...)
		end
		
	end
	
	table.insert(DAK.serveradmincommands, { name = fixedCommandName, help = helpText or "No help provided" })
	if DAK.serveradmincommandshooks[commandName] == nil then
		DAK.serveradmincommandshooks[commandName] = true
		Event.Hook(commandName, DAK:GetServerAdminFunction(commandName))
	end
	
end

//Internal Globals
function DAK:CreateServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)
	//Prefered function for creating ServerAdmin commands, not checked against blacklist
	CreateBaseServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)
end

function CreateServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)
	//Should catch other plugins commands, filters against blacklist to prevent defaults from being registered twice.
	for c = 1, #DAK.config.baseadmincommands.kBlacklistedCommands do
		local command = DAK.config.baseadmincommands.kBlacklistedCommands[c]
		if commandName == command then
			return
		end
	end
	//Assume its not blacklisted and proceed.
	CreateBaseServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)
end

function DAK:IsClientBanned(client)
	if client ~= nil then
		return DAK:IsNS2IDBanned(client:GetUserId())		
	end
	return false, ""
end

function DAK:IsNS2IDBanned(playerId)
	playerId = tonumber(playerId)
	if playerId ~= nil then
		local bentry = DAK.bannedplayers[playerId]
		if bentry ~= nil then
			local now = Shared.GetSystemTime()
			if bentry.time == 0 or now < bentry.time then
				return true, bentry.reason or "Banned"
			else
				LoadBannedPlayers()
				DAK.bannedplayers[playerId] = nil
				SaveBannedPlayers()
			end
		end
		if DAK.bannedplayersweb ~= nil then
			local bwentry = DAK.bannedplayersweb[playerId]
			if bwentry ~= nil then
				local now = Shared.GetSystemTime()
				if bwentry.time == 0 or now < bwentry.time then
					return true, bwentry.reason or "Banned"
				else
					DAK.bannedplayersweb[playerId] = nil
					SaveBannedPlayersWeb()
				end
			end
		end
	end
	return false, ""
end

function DAK:UnBanNS2ID(playerId)
	playerId = tonumber(playerId)
	if playerId ~= nil then
		LoadBannedPlayers()
		if DAK.bannedplayers[playerId] ~= nil then
			DAK.bannedplayers[playerId] = nil
			SaveBannedPlayers()
			return true
		end
		if DAK.bannedplayersweb ~= nil and DAK.bannedplayersweb[playerId] ~= nil then
			//Submit unban with key
			//DAK.config.serveradmin.UnBanSubmissionURL
			//DAK.config.serveradmin.CryptographyKey
			//OnPlayerUnBannedResponse
			//Shared.SendHTTPRequest(DAK.config.serveradmin.UnBanSubmissionURL, "GET", OnPlayerUnBannedResponse)
			return true
		end
	end
	return false
end

function DAK:UnBanSteamID(steamId)
	local ns2id = DAK:GetNS2IDFromSteamID(steamId)
	if ns2id ~= nil then
		return DAK:UnBanNS2ID(ns2id)
	end
	return false
end

function DAK:AddNS2IDBan(playerId, pname, duration, breason)
	playerId = tonumber(playerId)
	if playerId ~= nil then
		local bannedUntilTime = Shared.GetSystemTime()
		duration = tonumber(duration)
		if duration == nil or duration <= 0 then
			bannedUntilTime = 0
		else
			bannedUntilTime = bannedUntilTime + (duration * 60)
		end
		local bentry = { name = pname, reason = breason, time = bannedUntilTime }
		
		if DAK.config.serveradmin.BanSubmissionURL ~= "" then
			//Submit ban with key, working on logic to hash key
			//Should these be both submitted to database and logged on server?  My thinking is no here, so going with that moving forward.
			//DAK.config.serveradmin.BanSubmissionURL
			//DAK.config.serveradmin.CryptographyKey
			//Will also want ban response function to reload web bans.
			//OnPlayerBannedResponse
			//Shared.SendHTTPRequest(DAK.config.serveradmin.BanSubmissionURL, "POST", bentry, OnPlayerBannedResponse)
		else
			LoadBannedPlayers()
			DAK.bannedplayers[playerId] = bentry
			SaveBannedPlayers()
		end
		
		return true
	end
	return false
end