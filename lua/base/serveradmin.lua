//DAK loader/Base Config

DAK.adminsettings = { groups = { }, users = { } }
DAK.serveradmincommands = { }
DAK.serveradmincommandsfunctions = { }
DAK.serveradmincommandshooks = { }

local ServerAdminFileName = "config://ServerAdmin.json"
local ServerAdminWebFileName = "config://ServerAdminWeb.json"
local ServerAdminWebCache
local initialwebupdate = 0
local lastwebupdate = 0
	
local function LoadServerAdminSettings()

	Shared.Message("Loading " .. ServerAdminFileName)
	
	local initialState = { groups = { }, users = { } }
	DAK.adminsettings = initialState
	
	local configFile = io.open(ServerAdminFileName, "r")
	if configFile then
		local fileContents = configFile:read("*all")
		DAK.adminsettings = json.decode(fileContents) or initialState
		io.close(configFile)
	else
		local defaultConfig = {
								groups =
									{
									  admin_group = { type = "disallowed", commands = { }, level = 10 },
									  mod_group = { type = "allowed", commands = { "sv_reset", "sv_ban" }, level = 5 }
									},
								users =
									{
									  NsPlayer = { id = 10000001, groups = { "admin_group" }, level = 2 }
									}
							  }
		local configFile = io.open(ServerAdminFileName, "w+")
		configFile:write(json.encode(defaultConfig, { indent = true, level = 1 }))
		io.close(configFile)
	end
	assert(DAK.adminsettings.groups, "groups must be defined in " .. ServerAdminFileName)
	assert(DAK.adminsettings.users, "users must be defined in " .. ServerAdminFileName)
	
end

LoadServerAdminSettings()

local function LoadServerAdminWebSettings()

	Shared.Message("Loading " .. ServerAdminWebFileName)
	
	local configFile = io.open(ServerAdminWebFileName, "r")
	local users
	if configFile then
		local fileContents = configFile:read("*all")
		users = json.decode(fileContents)
		io.close(configFile)
	end
	ServerAdminWebCache = users
	return users
	
end

local function SaveServerAdminWebSettings(users)
	local configFile = io.open(ServerAdminWebFileName, "w+")
	if configFile ~= nil and users ~= nil then
		configFile:write(json.encode(users, { indent = true, level = 1 }))
		io.close(configFile)
	end
	ServerAdminWebCache = users
end	

//Global Group related functions
function DAK:GetGroupCanRunCommand(groupName, commandName)

	local group = DAK.adminsettings.groups[groupName]
	if not group then
		error("There is no group defined with name: " .. groupName)
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
		error("Only \"allowed\" and \"disallowed\" are valid terms for the type of the admin group")
	end
	
end

function DAK:GetClientCanRunCommand(client, commandName)

	// Convert to the old Steam Id format.
	local steamId = client:GetUserId()
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == steamId then
		
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
	local steamId = client:GetUserId()
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == steamId then
			for g = 1, #user.groups do
				local groupName = user.groups[g]
				if groupName == gpName then
					return true
				end
			end
		end
        return level
    end
end
	
function DAK:AddSteamIDToGroup(steamId, groupNameToAdd)
	for name, user in pairs(DAK.adminsettings.users) do
		if user.id == steamId then
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

function DAK:RemoveSteamIDFromGroup(steamId, groupNameToRemove)
	for name, user in pairs(DAK.adminsettings.users) do
		if user.id == steamId then
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
local function GetSteamIDLevel(steamId)

	local level = 0
	for name, user in pairs(DAK.adminsettings.users) do
	
		if user.id == steamId then
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
	local steamId = client:GetUserId()
	if steamId == nil then return 0 end
	return GetSteamIDLevel(steamId)
end

local function GetPlayerLevel(player)
	local client = Server.GetOwner(player)
	if client == nil then return 0 end
	local steamId = client:GetUserId()
	if steamId == nil then return 0 end
	return GetSteamIDLevel(steamId)
end

local function GetObjectLevel(target)
	if tonumber(target) ~= nil then
		return GetSteamIDLevel(tonumber(target))
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

local function tablemerge(tab1, tab2)
	if tab2 ~= nil then
		for k, v in pairs(tab2) do
			if (type(v) == "table") and (type(tab1[k] or false) == "table") then
				tablemerge(tab1[k], tab2[k])
			else
				tab1[k] = v
			end
		end
	end
	return tab1
end

local function ProcessWebResponse(response)
	local sstart = string.find(response,"<body>")
	if type(sstart) == "number" then
		local rstring = string.sub(response, sstart)
		if rstring then
			rstring = rstring:gsub("<body>\n", "{")
			rstring = rstring:gsub("<body>", "{")
			rstring = rstring:gsub("</body>", "}")
			rstring = rstring:gsub("<div id=\"username\"> ", "\"")
			rstring = rstring:gsub(" </div> <div id=\"steamid\"> ", "\": { \"id\": ")
			rstring = rstring:gsub(" </div> <div id=\"group\"> ", ", \"groups\": [ \"")
			rstring = rstring:gsub("\\,", "\", \"")
			rstring = rstring:gsub(" </div> <br>", "\" ] },")
			rstring = rstring:gsub("\n", "")
			return json.decode(rstring)
		end
	end
	return nil
end

local function OnServerAdminWebResponse(response)
	if response then
		local addusers = ProcessWebResponse(response)
		if addusers and ServerAdminWebCache ~= addusers then
			//If loading from file, that wont update so its not an issue.  However web queries are realtime so admin abilities can expire mid game and/or be revoked.  Going to have this reload and
			//purge old list, will insure greater accuracy (still has a couple loose ends).  Considering also adding a periodic check, or a check on command exec (still wouldnt be perfect), this seems good for now.
			LoadServerAdminSettings()
			DAK.adminsettings.users = tablemerge(DAK.adminsettings.users, addusers)
			SaveServerAdminWebSettings(addusers)
		end
	end
end

local function QueryForAdminList()
	Shared.SendHTTPRequest(DAK.config.serveradmin.QueryURL, "GET", OnServerAdminWebResponse)
	lastwebupdate = Shared.GetTime()
end

local function OnServerAdminClientConnect(client)
	local tt = Shared.GetTime()
	if tt > DAK.config.serveradmin.MapChangeDelay and (lastwebupdate == nil or (lastwebupdate + DAK.config.serveradmin.UpdateDelay) < tt) and DAK.config.serveradmin.QueryURL ~= "" and initialwebupdate ~= 0 then
		QueryForAdminList()
	end
end

DAK:RegisterEventHook("OnClientConnect", OnServerAdminClientConnect, 5)

local function DelayedServerCommandRegistration()
	if DAK.config.serveradmin.QueryURL ~= "" and initialwebupdate == 0 then
		QueryForAdminList()
		initialwebupdate = Shared.GetTime() + DAK.config.serveradmin.QueryTimeout	
	end
	if DAK.config.serveradmin.QueryURL ~= "" and initialwebupdate < Shared.GetTime() then
		if ServerAdminWebCache == nil then
			Shared.Message("ServerAdmin WebQuery failed, falling back on cached list.")
			DAK.adminsettings.users = tablemerge(DAK.adminsettings.users, LoadServerAdminWebSettings())
			initialwebupdate = 0
		end
	end
	if Shared.GetTime() > DAK.config.serveradmin.ReconnectTime then
		if DAK.settings.connectedclients ~= nil then
			for r = #DAK.settings.connectedclients, 1, -1 do
				if DAK.settings.connectedclients[r] ~= nil and DAK:GetClientMatchingSteamId(DAK.settings.connectedclients[r].id) == nil then
					DAK.settings.connectedclients[r] = nil
				end
			end
			DAK:SaveSettings()
		end
		DAK:DeregisterEventHook("OnServerUpdate", DelayedServerCommandRegistration)
	end
end

DAK:RegisterEventHook("OnServerUpdate", DelayedServerCommandRegistration, 5)

local function OnCommandListAdmins(client)

	if DAK.adminsettings ~= nil then
		if DAK.adminsettings.groups ~= nil then
			for group, commands in pairs(DAK.adminsettings.groups) do
				if client ~= nil then
					ServerAdminPrint(client, string.format(group .. " - " .. ToString(commands)))
				end		
			end
		end

		if DAK.adminsettings.users ~= nil then
			for name, user in pairs(DAK.adminsettings.users) do
				local online = GetClientMatchingSteamId(user.id) ~= nil
				if client ~= nil then
					ServerAdminPrint(client, string.format(name .. " - " .. ToString(user) .. ConditionalValue(online, " - Online", " - Offline")))
				end		
			end
		end
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_listadmins", OnCommandListAdmins, "Will list all groups and admins.")

local function OnCommandWho(client)

	if DAK.adminsettings ~= nil then	
		if DAK.adminsettings.users ~= nil then
			for name, user in pairs(DAK.adminsettings.users) do
				local uclient = GetClientMatchingSteamId(user.id)
				local online = (uclient ~= nil)
				if online then
					local player = uclient:GetControllingPlayer()
					if player ~= nil then
						local pname = player:GetName()
						ServerAdminPrint(client, string.format(pname .. " - " .. name .. " - " .. ToString(user)))
					end	
				end
			end
		end
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_who", OnCommandWho, "Will list all online admins.", true)

local function PrintHelpForCommand(client, optionalCommand)

	for c = 1, #DAK.serveradmincommands do
	
		local command = DAK.serveradmincommands[c]
		if optionalCommand == command.name or optionalCommand == nil then
		
			if not client or DAK:GetClientCanRunCommand(client, command.name, false) then
				ServerAdminPrint(client, command.name .. ": " .. command.help)
			elseif optionalCommand then
				ServerAdminPrint(client, "You do not have access to " .. optionalCommand)
			end
			
		end
		
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_help", PrintHelpForCommand, "Prints help for all commands or the specified command.", true)

//This is so derp, but re-registering function to override builtin admin system without having to modify core NS2 files
//Using registration of ServerAdminPrint network message for the correct timing
local originalNS2CreateServerAdminCommand

originalNS2CreateServerAdminCommand = Class_ReplaceMethod("Shared", "RegisterNetworkMessage", 
	function(parm1, parm2)
	
		if parm1 == "ServerAdminPrint" then
			if DAK.config and DAK.config.baseadmincommands and DAK:IsPluginEnabled("baseadmincommands") then
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
			end
		end
		if parm2 == nil then
			originalNS2CreateServerAdminCommand(parm1)
		else
			originalNS2CreateServerAdminCommand(parm1, parm2)
		end

	end
)
