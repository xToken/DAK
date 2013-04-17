//DAK loader/Base Config

DAK.adminsettings = { groups = { }, users = { } }
DAK.bannedplayers = { }
DAK.bannedplayersweb = { }
DAK.serveradmincommands = { }
DAK.serveradmincommandsfunctions = { }
DAK.serveradmincommandshooks = { }

local ServerAdminFileName = "config://ServerAdmin.json"
local ServerAdminWebFileName = "config://ServerAdminWeb.json"
local BannedPlayersFileName = "config://BannedPlayers.json"
local BannedPlayersWebFileName = "config://BannedPlayersWeb.json"
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

local function LoadBannedPlayers()
	DAK.bannedplayers = DAK:ConvertFromOldBansFormat(DAK:LoadConfigFile(BannedPlayersFileName)) or { }
end

LoadBannedPlayers()

local function SaveBannedPlayers()
	DAK:SaveConfigFile(BannedPlayersFileName, DAK:ConvertToOldBansFormat(DAK.bannedplayers))
end

local function LoadServerAdminWebSettings()
	ServerAdminWebCache = DAK:LoadConfigFile(ServerAdminWebFileName) or { }
end

local function LoadBannedPlayersWeb()
	DAK.bannedplayersweb = DAK:LoadConfigFile(BannedPlayersWebFileName) or { }
end

local function SaveServerAdminWebSettings(users)
	DAK:SaveConfigFile(ServerAdminWebFileName, users)
	ServerAdminWebCache = users
end

local function SaveBannedPlayersWeb()
	DAK:SaveConfigFile(BannedPlayersWebFileName, DAK.bannedplayersweb)
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

local function OnServerAdminBansWebResponse(response)
	if response then
		local bannedusers = DAK:ConvertFromOldBansFormat(json.decode(response))
		if bannedusers and DAK.bannedplayersweb ~= bannedusers then
			DAK.bannedplayersweb = bannedusers
			SaveBannedPlayersWeb()
		end
	end
end

local function QueryForAdminList()
	if DAK.config.serveradmin.QueryURL ~= "" then
		Shared.SendHTTPRequest(DAK.config.serveradmin.QueryURL, "GET", OnServerAdminWebResponse)
	end
end

local function QueryForBansList()
	if DAK.config.serveradmin.BansQueryURL ~= "" then
		Shared.SendHTTPRequest(DAK.config.serveradmin.BansQueryURL, "GET", OnServerAdminBansWebResponse)
	end
end

local function OnPlayerBannedResponse(response)
	if response == "TRUE" then
		//ban successful, update webbans using query URL.
		QueryForBansList()
	end
end

local function OnPlayerUnBannedResponse(response)
	if response == "TRUE" then
		//Unban successful, anything needed here?
	end
end

local function OnServerAdminClientConnect(client)
	local isBanned, Reason = DAK:IsClientBanned(client)
	if isBanned then
		client.disconnectreason = Reason
		Server.DisconnectClient(client)
		return true
	end
	local tt = Shared.GetTime()
	if tt > DAK.config.serveradmin.MapChangeDelay and (lastwebupdate == nil or (lastwebupdate + DAK.config.serveradmin.UpdateDelay) < tt) then
		QueryForAdminList()
		QueryForBansList()
		lastwebupdate = tt
	end
end

DAK:RegisterEventHook("OnClientConnect", OnServerAdminClientConnect, 6, "serveradmin")

local function CheckServerAdminQueries()
	if DAK.config.serveradmin.QueryURL ~= "" and ServerAdminWebCache == nil then
		Shared.Message("ServerAdmin WebQuery failed, falling back on cached list.")
		DAK.adminsettings.users = tablemerge(DAK.adminsettings.users, LoadServerAdminWebSettings())
	end
	if DAK.config.serveradmin.BansQueryURL ~= "" and DAK.bannedplayersweb == nil then
		Shared.Message("Bans WebQuery failed, falling back on cached list.")
		LoadBannedPlayersWeb()
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
	QueryForBansList()
	DAK:SetupTimedCallBack(CheckServerAdminQueries, DAK.config.serveradmin.QueryTimeout)
	DAK:SetupTimedCallBack(UpdateClientConnectionTime, DAK.config.serveradmin.ReconnectTime)
end

DAK:RegisterEventHook("OnPluginInitialized", DelayedServerCommandRegistration, 5, "serveradmin")

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

//Block Default ServerAdmin load
DAK:OverrideScriptLoad("lua/ServerAdmin.lua")