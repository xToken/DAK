//DAK 

DAK.bannedplayers = { }
DAK.bannedplayersweb = { }

local BannedPlayersFileName = "config://BannedPlayers.json"
local BannedPlayersWebFileName = "config://BannedPlayersWeb.json"
local lastwebupdate = 0
	
local function LoadBannedPlayers()
	DAK.bannedplayers = DAK:ConvertFromOldBansFormat(DAK:LoadConfigFile(BannedPlayersFileName)) or { }
end

LoadBannedPlayers()

local function SaveBannedPlayers()
	DAK:SaveConfigFile(BannedPlayersFileName, DAK:ConvertToOldBansFormat(DAK.bannedplayers))
end

local function LoadBannedPlayersWeb()
	DAK.bannedplayersweb = DAK:ConvertFromOldBansFormat(DAK:LoadConfigFile(BannedPlayersWebFileName)) or { }
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

local function OnServerAdminBansWebResponse(response)
	if response then
		local bannedusers = DAK:ConvertFromOldBansFormat(json.decode(response))
		if bannedusers and DAK.bannedplayersweb ~= bannedusers then
			DAK.bannedplayersweb = bannedusers
			SaveBannedPlayersWeb()
		end
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
		QueryForBansList()
		lastwebupdate = tt
	end
end

DAK:RegisterEventHook("OnClientConnect", OnServerAdminClientConnect, 6, "serveradminbans")

local function CheckServerAdminQueries()
	if DAK.config.serveradmin.BansQueryURL ~= "" and DAK.bannedplayersweb == nil then
		Shared.Message("Bans WebQuery failed, falling back on cached list.")
		LoadBannedPlayersWeb()
	end
	return false
end

local function DelayedServerCommandRegistration()
	QueryForBansList()
	DAK:SetupTimedCallBack(CheckServerAdminQueries, DAK.config.serveradmin.QueryTimeout)
end

DAK:RegisterEventHook("OnPluginInitialized", DelayedServerCommandRegistration, 5, "serveradminbans")

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
					DAK.bannedplayers[playerId] = nil
					SaveBannedPlayersWeb()
				end
			end
		end
	end
	return false, ""
end

function DAK:UnBanNS2ID(playerId, adminns2Id)
	playerId = tonumber(playerId)
	if playerId ~= nil then
		LoadBannedPlayers()
		if DAK.bannedplayers[playerId] ~= nil then
			DAK.bannedplayers[playerId] = nil
			SaveBannedPlayers()
			return true
		end
		if DAK.bannedplayersweb ~= nil and DAK.bannedplayersweb[playerId] ~= nil and DAK.config.serveradmin.UnBanSubmissionURL ~= "" then
			//Submit unban with key.
			local bentry = { key = DAK.config.serveradmin.BanSubmissionKey, id = playerId, adminid = adminns2Id }
			Shared.SendHTTPRequest(DAK.config.serveradmin.UnBanSubmissionURL, "POST", {data=json.encode(bentry)}, OnPlayerUnBannedResponse)
			return true
		end
	end
	return false
end

function DAK:UnBanSteamID(steamId, adminns2Id)
	local ns2id = DAK:GetNS2IDFromSteamID(steamId)
	if ns2id ~= nil then
		return DAK:UnBanNS2ID(ns2id, adminns2Id)
	end
	return false
end

function DAK:AddNS2IDBan(playerId, pname, duration, breason, adminns2Id)
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
			//Submit ban with key.
			//Should these be both submitted to database and logged on server?  My thinking is no here, so going with that moving forward.
			//Will also want ban response function to reload web bans.
			//OnPlayerBannedResponse
			bentry.key = DAK.config.serveradmin.BanSubmissionKey
			bentry.adminid = adminns2Id
			bentry.id = playerId
			Shared.SendHTTPRequest(DAK.config.serveradmin.BanSubmissionURL, "POST", {data=json.encode(bentry)}, OnPlayerBannedResponse)
			DAK:SaveConfigFile("config://BannedPlayersWebTest.json", {data=json.encode(bentry)})
		else
			LoadBannedPlayers()
			DAK.bannedplayers[playerId] = bentry
			SaveBannedPlayers()
		end
		return true
	end
	return false
end