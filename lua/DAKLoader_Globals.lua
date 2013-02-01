//DAK Loader/Base Config

function DAKIsPluginEnabled(CheckPlugin)
	for index, plugin in pairs(kDAKConfig.DAKLoader.kPluginsList) do
		if CheckPlugin == plugin then
			return true
		end
	end
	return false
end

function EnhancedLog(message)

	if DAKIsPluginEnabled("enhancedlogging") then
		EnhancedLogMessage(message)
	end

end
	
function PrintToAllAdmins(commandname, client, parm1)

	if DAKIsPluginEnabled("enhancedlogging") then
		EnhancedLoggingAllAdmins(commandname, client, parm1)
	end

end

function DAKCreateGUIVoteBase(id, OnMenuFunction, OnMenuUpdateFunction)
	if DAKIsPluginEnabled("guimenubase") then
		//return CreateGUIMenuBase(id, OnMenuFunction, OnMenuUpdateFunction)
	end
	return false
end

function DAKIsPlayerAFK(player)
	if DAKIsPluginEnabled("afkkick") then
		return GetIsPlayerAFK(player)
	elseif player ~= nil and player:GetAFKTime() > 30 then
		return true
	end
	return false
end

function ShufflePlayerList()

	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	for i = #playerList, 1, -1 do
		if playerList[i]:GetTeamNumber() ~= 0 or DAKIsPlayerAFK(playerList[i]) then
			table.remove(playerList, i)
		end
	end
	for i = 1, (#playerList) do
		r = math.random(1, #playerList)
		local iplayer = playerList[i]
		playerList[i] = playerList[r]
		playerList[r] = iplayer
	end
	return playerList
	
end

function GetTournamentMode()
	local OverrideTournamentModes = false
	if RBPSconfig then
		//Gonna do some basic NS2Stats detection here
		OverrideTournamentModes = RBPSconfig.tournamentMode
	end
	if kDAKSettings.TournamentMode == nil then
		kDAKSettings.TournamentMode = false
	end
	return kDAKSettings.TournamentMode or OverrideTournamentModes
end

function GetFriendlyFire()
	if kDAKSettings.FriendlyFire == nil then
		kDAKSettings.FriendlyFire = false
	end
	return kDAKSettings.FriendlyFire
end

function GetClientUIDString(client)

	if client ~= nil then
		local player = client:GetControllingPlayer()
		local name = "N/A"
		local teamnumber = 0
		if player ~= nil then
			name = player:GetName()
			teamnumber = player:GetTeamNumber()
		end
		return string.format("<%s><%s><%s><%s>", name, ToString(GetGameIdMatchingClient(client)), client:GetUserId(), teamnumber)
	end
	return ""
	
end

//Client ID Translators
function VerifyClient(client)

	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local plyr = playerList[r]
			local clnt = playerList[r]:GetClient()
			if plyr ~= nil and clnt ~= nil then
				if client ~= nil and clnt == client then
					return clnt
				end
			end
		end				
	end
	return nil

end

function GetPlayerMatching(id)

	local player = GetPlayerMatchingName(tostring(id))
	if player then
		return player
	else
		local idNum = tonumber(id)
		if idNum then
			return GetPlayerMatchingGameId(idNum) or GetPlayerMatchingSteamId(idNum)
		end
	end
	
end

function GetClientMatchingSteamId(steamId)

	assert(type(steamId) == "number")
	
	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local plyr = playerList[r]
			local clnt = playerList[r]:GetClient()
			if plyr ~= nil and clnt ~= nil then
				if clnt:GetUserId() == steamId then
					return clnt
				end
			end
		end				
	end
	
	return nil
	
end

function GetPlayerMatchingSteamId(steamId)

	assert(type(steamId) == "number")
	
	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local plyr = playerList[r]
			local clnt = playerList[r]:GetClient()
			if plyr ~= nil and clnt ~= nil then
				if clnt:GetUserId() == steamId then
					return plyr
				end
			end
		end				
	end
	
	return nil
	
end

function GetPlayerMatchingName(name)

	assert(type(name) == "string")
	
	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	for r = #playerList, 1, -1 do
		if playerList[r] ~= nil then
			local plyr = playerList[r]
			if plyr:GetName() == name then
				return plyr
			end
		end
	end
	
	return nil
	
end