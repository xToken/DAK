//DAK loader/Base Config

DAK.adminsettings = { groups = { }, users = { } }
DAK.serveradmincommands = { }
DAK.serveradmincommandsfunctions = { }
DAK.serveradmincommandshooks = { }

local ServerAdminFileName = "config://ServerAdmin.json"
local ServerAdminWebFileName = "config://ServerAdminWeb.json"
local ServerAdminWebCache = nil
local lastwebupdate = 0
	
local function LoadServerAdminSettings()
	
	local defaultConfig = {
								groups =
									{
									  admin_group = { type = "disallowed", commands = { }, level = 10 },
									  mod_group = { type = "allowed", commands = { "sv_reset", "sv_kick" }, level = 5 }
									},
								users =
									{
									  NsPlayer = { id = 10000001, groups = { "admin_group" }, level = 2 }
									}
							  }
	DAK:WriteDefaultConfigFile(ServerAdminFileName, defaultConfig)
	
	DAK.adminsettings = DAK:LoadConfigFile(ServerAdminFileName) or defaultConfig
	
	assert(DAK.adminsettings.groups, "groups must be defined in " .. ServerAdminFileName)
	assert(DAK.adminsettings.users, "users must be defined in " .. ServerAdminFileName)
	
end

LoadServerAdminSettings()

local function LoadServerAdminWebSettings()
	ServerAdminWebCache = DAK:LoadConfigFile(ServerAdminWebFileName) or { }
end

local function SaveServerAdminWebSettings(users)
	DAK:SaveConfigFile(ServerAdminWebFileName, users)
	ServerAdminWebCache = users
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

local function ProcessAdminsWebResponse(response)
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
		local addusers = ProcessAdminsWebResponse(response)
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
	if DAK.config.serveradmin.QueryURL ~= "" then
		Shared.SendHTTPRequest(DAK.config.serveradmin.QueryURL, "GET", OnServerAdminWebResponse)
	end
end

local function OnServerAdminClientConnect(client)
	local tt = Shared.GetTime()
	if tt > DAK.config.serveradmin.MapChangeDelay and (lastwebupdate == nil or (lastwebupdate + DAK.config.serveradmin.UpdateDelay) < tt) then
		QueryForAdminList()
		lastwebupdate = tt
	end
end

DAK:RegisterEventHook("OnClientConnect", OnServerAdminClientConnect, 5, "serveradminusers")

local function CheckServerAdminQueries()
	if DAK.config.serveradmin.QueryURL ~= "" and ServerAdminWebCache == nil then
		Shared.Message("ServerAdmin WebQuery failed, falling back on cached list.")
		DAK.adminsettings.users = tablemerge(DAK.adminsettings.users, LoadServerAdminWebSettings())
	end
	return false
end

local function UpdateClientConnectionTime()
	if DAK.settings.connectedclients == nil then
		DAK.settings.connectedclients = { }
	end
	for id, conntime in pairs(DAK.settings.connectedclients) do
		if DAK:GetClientMatchingNS2Id(tonumber(id)) == nil then
			DAK.settings.connectedclients[id] = nil
		end
	end
	DAK:SaveSettings()
	return false
end

local function DelayedServerCommandRegistration()
	QueryForAdminList()
	DAK:SetupTimedCallBack(CheckServerAdminQueries, DAK.config.serveradmin.QueryTimeout)
	DAK:SetupTimedCallBack(UpdateClientConnectionTime, DAK.config.serveradmin.ReconnectTime)
end

DAK:RegisterEventHook("OnPluginInitialized", DelayedServerCommandRegistration, 5, "serveradminusers")

local kMaxPrintLength = 128
local kServerAdminMessage =
{
	message = string.format("string (%d)", kMaxPrintLength),
}
Shared.RegisterNetworkMessage("ServerAdminPrint", kServerAdminMessage)

function ServerAdminPrint(client, message)

	if client then
	
		// First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
		local messageList = { }
		while string.len(message) > kMaxPrintLength do
		
			local messagePart = string.sub(message, 0, kMaxPrintLength)
			table.insert(messageList, messagePart)
			message = string.sub(message, kMaxPrintLength + 1)
			
		end
		table.insert(messageList, message)
		
		for m = 1, #messageList do
			Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint", { message = messageList[m] }, true)
		end
		
	else
	
		Shared.Message(message)
		
	end
	
end

//Block Default ServerAdmin load
DAK:OverrideScriptLoad("lua/ServerAdmin.lua")