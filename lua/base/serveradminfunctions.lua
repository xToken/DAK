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
	//Convert to the old Steam Id format.
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
	elseif DAK:VerifyClient(target) then
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
	
	table.insert(DAK.serveradmincommands, { name = fixedCommandName, help = helpText or "No help provided", alwaysallowed = optionalAlwaysAllowed })
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
	if DAK.config.baseadmincommands ~= nil then
		for c = 1, #DAK.config.baseadmincommands.kBlacklistedCommands do
			local command = DAK.config.baseadmincommands.kBlacklistedCommands[c]
			if commandName == command then
				return
			end
		end
	end
	//Assume its not blacklisted and proceed.
	CreateBaseServerAdminCommand(commandName, commandFunction, helpText, optionalAlwaysAllowed)
end