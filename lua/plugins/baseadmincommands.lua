//Base Admin Commands
//This is designed to replace the base admin commands.

local function GetPlayerList()

	local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
	table.sort(playerList, function(p1, p2) return p1:GetName() < p2:GetName() end)
	return playerList
	
end

/**
 * Iterates over all players sorted in alphabetically calling the passed in function.
 */
local function AllPlayers(doThis)

	return function(client)
	
		local playerList = GetPlayerList()
		for p = 1, #playerList do
		
			local player = playerList[p]
			doThis(player, client, p)
			
		end
		
	end
	
end

local function PrintStatus(player, client, index)

	local playerClient = Server.GetOwner(player)
	if not playerClient then
		Shared.Message("playerClient is nil in PrintStatus, alert Brian")
	else
		
		if DAK:GetClientCanRunCommand(client, "sv_status") then
			local playerAddressString = IPAddressToString(Server.GetClientAddress(playerClient))
			ServerAdminPrint(client, player:GetName() .. " : Game Id = " 
			.. ToString(DAK:GetGameIdMatchingClient(playerClient))
			.. " : Steam Id = " .. playerClient:GetUserId()
			.. " : Team = " .. player:GetTeamNumber()
			.. " : Address = " .. playerAddressString
			.. " : Connection Time = " .. DAK:GetClientConnectionTime(playerClient))
		else
			ServerAdminPrint(client, player:GetName() .. " : Game Id = " 
			.. ToString(DAK:GetGameIdMatchingClient(playerClient))
			.. " : Steam Id = " .. playerClient:GetUserId()
			.. " : Team = " .. player:GetTeamNumber())
		end

	end
	
end

DAK:CreateServerAdminCommand("Console_sv_status", AllPlayers(PrintStatus), "Lists player Ids and names for use in sv commands", true)

local function OnCommandChangeMap(client, mapName)

	DAK:PrintToAllAdmins("sv_changemap", client, mapName)

	if MapCycle_VerifyMapName(mapName) then
		MapCycle_ChangeToMap(mapName)
	else
		DAK:DisplayMessageToClient(client, "InvalidMap")
	end
	
end
DAK:CreateServerAdminCommand("Console_sv_changemap", OnCommandChangeMap, "<map name> Switches to the map specified")

local function OnCommandSVReset(client)

	DAK:PrintToAllAdmins("sv_reset", client)
	local gamerules = GetGamerules()
	if gamerules then
		gamerules:ResetGame()
	end
	ServerAdminPrint(client, string.format("Game was reset."))
	
end

DAK:CreateServerAdminCommand("Console_sv_reset", OnCommandSVReset, "Resets the game round")

local function OnCommandSVrrall(client)

	DAK:PrintToAllAdmins("sv_rrall", client)
	local playerList = GetPlayerList()
	for i = 1, (#playerList) do
		local gamerules = GetGamerules()
		if gamerules then
			gamerules:JoinTeam(playerList[i], kTeamReadyRoom)
		end
	end
	ServerAdminPrint(client, string.format("All players were moved to the ReadyRoom."))
	
end
	
DAK:CreateServerAdminCommand("Console_sv_rrall", OnCommandSVrrall, "Forces all players to go to the Ready Room")

local function OnCommandSVRandomall(client)

	DAK:PrintToAllAdmins("sv_randomall", client)
	local playerList = DAK:ShuffledPlayerList()
	for i = 1, (#playerList) do
		if playerList[i]:GetTeamNumber() == 0 then
			local teamnum = math.fmod(i,2) + 1
			//Trying just making team decision based on position in array.. two randoms seems to somehow result in similar teams..
			local gamerules = GetGamerules()
			if gamerules then
				if not gamerules:GetCanJoinTeamNumber(teamnum) and gamerules:GetCanJoinTeamNumber(math.fmod(teamnum,2) + 1) then
					teamnum = math.fmod(teamnum,2) + 1						
				end
				gamerules:JoinTeam(playerList[i], teamnum)
			end
		end
	end
	ServerAdminPrint(client, string.format("Teams were Randomed."))
	
end

DAK:CreateServerAdminCommand("Console_sv_randomall", OnCommandSVRandomall, "Forces all players to join a random team")

local function SwitchTeam(client, playerId, team)

	local player = DAK:GetPlayerMatching(playerId)
	local teamNumber = tonumber(team)
	
	if not DAK:GetLevelSufficient(client, player) then
		return
	end
	
	if type(teamNumber) ~= "number" or teamNumber < 0 or teamNumber > 3 then
	
		ServerAdminPrint(client, "Invalid team number")
		return
		
	end
	
	if player and teamNumber ~= player:GetTeamNumber() then
		local gamerules = GetGamerules()
		if gamerules then
			gamerules:JoinTeam(player, teamNumber)
		end
		ServerAdminPrint(client, string.format("Player %s was moved to team %s.", player:GetName(), teamNumber))
		local switchedclient = Server.GetOwner(player)
		if switchedclient then
			DAK:PrintToAllAdmins("sv_switchteam", client, string.format("on %s to team %s.", DAK:GetClientUIDString(switchedclient), teamNumber))
		end
	elseif not player then
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_switchteam", SwitchTeam, "<player id> <team number> Moves passed player to provided team. 1 is Marine, 2 is Alien.")

local function Eject(client, playerId)

	local player = DAK:GetPlayerMatching(playerId)
	
	if not DAK:GetLevelSufficient(client, player) then
		return
	end
	
	if player and player:isa("Commander") then
		ServerAdminPrint(client, "Player " .. player:GetName() .. "was ejected.")
		player:Eject()
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_eject", Eject, "<player id> Ejects Commander from the Command Structure")

local function Kick(client, playerId)

	local player = DAK:GetPlayerMatching(playerId)
	
	if not DAK:GetLevelSufficient(client, player) then
		return
	end
	
	if player then
		local kickedclient = Server.GetOwner(player)
		if kickedclient then
			ServerAdminPrint(client, "Player " .. player:GetName() .. " was kicked.")
			DAK:PrintToAllAdmins("sv_kick", client, string.format("on %s.", DAK:GetClientUIDString(kickedclient)))
			kickedclient.disconnectreason = "Kicked"
			Server.DisconnectClient(kickedclient)
		end
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_kick", Kick, "<player id> Kicks the player from the server")

local function GetChatMessage(...)

	local chatMessage = StringConcatArgs(...)
	if chatMessage then
		return string.sub(chatMessage, 1, kMaxChatLength)
	end
	
	return ""
	
end

local function Say(client, ...)

	local chatMessage = GetChatMessage(...)
	if string.len(chatMessage) > 0 then
	
		Server.SendNetworkMessage("Chat", BuildChatMessage(false, DAK.config.language.MessageSender, -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
		Shared.Message("Chat All - Admin: " .. chatMessage)
		Server.AddChatToHistory(chatMessage, DAK.config.language.MessageSender, 0, kTeamReadyRoom, false)
		
	end
	
	if string.len(chatMessage) > 0 then 
		DAK:PrintToAllAdmins("sv_say", client, chatMessage)
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_say", Say, "<message> Sends a message to every player on the server")

local function TeamSay(client, team, ...)

	local teamNumber = tonumber(team)
	if type(teamNumber) ~= "number" or teamNumber < 0 or teamNumber > 3 then
	
		ServerAdminPrint(client, "Invalid team number")
		return
		
	end
	
	local chatMessage = GetChatMessage(...)
	if string.len(chatMessage) > 0 then
	
		local players = GetEntitiesForTeam("Player", teamNumber)
		for index, player in ipairs(players) do
			Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "Team - " .. DAK.config.language.MessageSender, -1, teamNumber, kNeutralTeamType, chatMessage), true)
		end
		
		Shared.Message("Chat Team - Admin: " .. chatMessage)
		Server.AddChatToHistory(chatMessage, DAK.config.language.MessageSender, 0, teamNumber, true)
		
	end
	
	if string.len(chatMessage) > 0 then 
		DAK:PrintToAllAdmins("sv_tsay", client, chatMessage)
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_tsay", TeamSay, "<team number> <message> Sends a message to one team")

local function PlayerSay(client, playerId, ...)

	local chatMessage = GetChatMessage(...)
	local player = DAK:GetPlayerMatching(playerId)
	
	if player then
	
		chatMessage = string.sub(chatMessage, 1, kMaxChatLength)
		if string.len(chatMessage) > 0 then
		
			Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "PM - " .. DAK.config.language.MessageSender, -1, teamNumber, kNeutralTeamType, chatMessage), true)
			Shared.Message("Chat Player - Admin: " .. chatMessage)
			
		end
		
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
	if string.len(chatMessage) > 0 then 
		DAK:PrintToAllAdmins("sv_psay", client, chatMessage)
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_psay", PlayerSay, "<player id> <message> Sends a message to a single player")

local function Slay(client, playerId)

	local player = DAK:GetPlayerMatching(playerId)
	
	if not DAK:GetLevelSufficient(client, player) then
		return
	end
	
	if player then
		player:Kill(nil, nil, player:GetOrigin())
		ServerAdminPrint(client, "Player " .. player:GetName() .. " was slayed.")
		local slayedclient = Server.GetOwner(player)
		if slayedclient then
			DAK:PrintToAllAdmins("sv_slay", client, string.format("on %s.", DAK:GetClientUIDString(slayedclient)))
		end
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_slay", Slay, "<player id>, Kills player")

local function SetPassword(client, newPassword)
	Server.SetPassword(newPassword or "")
	ServerAdminPrint(client, "Server password changed to ********.")
	DAK:PrintToAllAdmins("sv_password", client, newPassword)		
end

DAK:CreateServerAdminCommand("Console_sv_password", SetPassword, "<string> Changes the password on the server")

local bannedPlayers = { }
local bannedPlayersFileName = "config://BannedPlayers.json"
local bannedPlayersWeb = { }
local bannedPlayersWebFileName = "config://BannedPlayersWeb.json"
local initialbannedwebupdate = 0
local lastbannedwebupdate = 0

local function LoadBannedPlayers()

	Shared.Message("Loading " .. bannedPlayersFileName)
	
	bannedPlayers = { }
	
	// Load the ban settings from file if the file exists.
	local bannedPlayersFile = io.open(bannedPlayersFileName, "r")
	if bannedPlayersFile then
		bannedPlayers = json.decode(bannedPlayersFile:read("*all")) or { }
		bannedPlayersFile:close()
	end
	
end

LoadBannedPlayers()

local function SaveBannedPlayers()

	local bannedPlayersFile = io.open(bannedPlayersFileName, "w+")
	if bannedPlayersFile then
		bannedPlayersFile:write(json.encode(bannedPlayers, { indent = true, level = 1 }))
		bannedPlayersFile:close()
	end
	
end

local function LoadBannedPlayersWeb()

	Shared.Message("Loading " .. bannedPlayersWebFileName)
	
	bannedPlayersWeb = { }
	
	// Load the ban settings from file if the file exists.
	local bannedPlayersWebFile = io.open(bannedPlayersWebFileName, "r")
	if bannedPlayersWebFile then
		bannedPlayersWeb = json.decode(bannedPlayersWebFile:read("*all")) or { }
		bannedPlayersWebFile:close()
	end
	
end

local function SaveBannedPlayersWeb()

	local bannedPlayersWebFile = io.open(bannedPlayersWebFileName, "w+")
	if bannedPlayersWebFile then
		bannedPlayersWebFile:write(json.encode(bannedPlayersWeb, { indent = true, level = 1 }))
		bannedPlayersWebFile:close()
	end
	
end

local function ProcessWebResponse(response)
	local sstart = string.find(response,"<body>")
	local rstring = string.sub(response, sstart)
	if rstring then
		rstring = rstring:gsub("<body>\n", "{")
		rstring = rstring:gsub("<body>", "{")
		rstring = rstring:gsub("</body>", "}")
		rstring = rstring:gsub("<div id=\"username\"> ", "\"")
		rstring = rstring:gsub(" </div> <div id=\"steamid\"> ", "\": { \"id\": ")
		rstring = rstring:gsub(" </div> <div id=\"group\"> ", ", \"groups\": [ \"")
		rstring = rstring:gsub(" </div> <br>", "\" ] },")
		rstring = rstring:gsub("\n", "")
		return json.decode(rstring)
	end
	return nil
end

local function OnServerAdminWebResponse(response)
	if response then
		local bannedusers = ProcessWebResponse(response)
		if bannedusers and bannedPlayersWeb ~= bannedusers then
			bannedPlayersWeb = bannedusers
			SaveBannedPlayersWeb()
		end
	end
end

local function QueryForBansList()
	if DAK.config.baseadmincommands.kBansQueryURL ~= "" then
		Shared.SendHTTPRequest(DAK.config.baseadmincommands.kBansQueryURL, "GET", OnServerAdminWebResponse)
	end
	lastbannedwebupdate = Shared.GetTime()
end

local function OnServerAdminClientConnect(client)
	local tt = Shared.GetTime()
	if tt > DAK.config.baseadmincommands.kMapChangeDelay and (lastbannedwebupdate == nil or (lastbannedwebupdate + DAK.config.baseadmincommands.kUpdateDelay) < tt) and DAK.config.baseadmincommands.kBansQueryURL ~= "" and initialbannedwebupdate ~= 0 then
		QueryForBansList()
	end
end

local function DelayedBannedPlayersWebUpdate()
	if DAK.config.baseadmincommands.kBansQueryURL == "" then
		DAK:DeregisterEventHook("OnServerUpdate", DelayedBannedPlayersWebUpdate)
		return
	end
	if initialbannedwebupdate == 0 then
		QueryForBansList()
		initialbannedwebupdate = Shared.GetTime() + DAK.config.baseadmincommands.kBansQueryTimeout		
	end
	if initialbannedwebupdate < Shared.GetTime() then
		if bannedPlayersWeb == nil then
			Shared.Message("Bans WebQuery failed, falling back on cached list.")
			LoadBannedPlayersWeb()
			initialbannedwebupdate = 0
		end
		DAK:DeregisterEventHook("OnServerUpdate", DelayedBannedPlayersWebUpdate)
	end
end

DAK:RegisterEventHook("OnServerUpdate", DelayedBannedPlayersWebUpdate, 5)

local function OnConnectCheckBan(client)

	OnServerAdminClientConnect()
	local steamid = client:GetUserId()
	for b = #bannedPlayers, 1, -1 do
	
		local ban = bannedPlayers[b]
		if ban.id == steamid then
		
			// Check if enough time has passed on a temporary ban.
			local now = Shared.GetSystemTime()
			if ban.time == 0 or now < ban.time then
			
				client.disconnectreason = "Banned"
				Server.DisconnectClient(client)
				return true
				
			else
			
				// No longer banned.
				LoadBannedPlayers()
				table.remove(bannedPlayers, b)
				SaveBannedPlayers()
				
			end
			
		end
		
	end
	
	for b = #bannedPlayersWeb, 1, -1 do
	
		local ban = bannedPlayersWeb[b]
		if ban.id == steamid then
		
			// Check if enough time has passed on a temporary ban.
			local now = Shared.GetSystemTime()
			if ban.time == 0 or now < ban.time then
			
				client.disconnectreason = "Banned"
				Server.DisconnectClient(client)
				return true
				
			else
			
				// No longer banned.
				// Remove to prevent confusion, but also should consider if this is supposed to update the PHPDB, or just assume that will handle expiring bans itself.
				table.remove(bannedPlayersWeb, b)
				SaveBannedPlayersWeb()
				
			end
			
		end
		
	end
	
end

DAK:RegisterEventHook("OnClientConnect", OnConnectCheckBan, 6)

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

/**
 * Duration is specified in minutes. Pass in 0 or nil to ban forever.
 * A reason string may optionally be provided.
 */
local function Ban(client, playerId, duration, ...)

	local player = DAK:GetPlayerMatching(playerId)
	local bannedUntilTime = Shared.GetSystemTime()
	duration = tonumber(duration)
	if duration == nil or duration <= 0 then
		bannedUntilTime = 0
	else
		bannedUntilTime = bannedUntilTime + (duration * 60)
	end
	
	if player then
	
		if not DAK:GetLevelSufficient(client, player) then
			return
		end
		
		local bannedclient = Server.GetOwner(player)
		if bannedclient then
		
			if DAK.config.baseadmincommands.kBanSubmissionURL ~= "" then
				//Submit ban with key, working on logic to hash key
				//Should these be both submitted to database and logged on server?  My thinking is no here, so going with that moving forward.
				//DAK.config.baseadmincommands.kBanSubmissionURL
				//DAK.config.baseadmincommands.kCryptographyKey
				//Will also want ban response function to reload web bans.
				//OnPlayerBannedResponse
				//Shared.SendHTTPRequest(DAK.config.baseadmincommands.kBanSubmissionURL, "POST", parms, OnPlayerBannedResponse)
			else
				LoadBannedPlayers()
				table.insert(bannedPlayers, { name = player:GetName(), id = bannedclient:GetUserId(), reason = StringConcatArgs(...), time = bannedUntilTime })
				SaveBannedPlayers()
			end
			
			ServerAdminPrint(client, player:GetName() .. " has been banned.")
			DAK:PrintToAllAdmins("sv_ban", client, string.format("on %s for %s for %s.", DAK:GetClientUIDString(bannedclient), duration, args))
			bannedclient.disconnectreason = "Banned"
			Server.DisconnectClient(bannedclient)
			
		end		
		
	elseif tonumber(playerId) > 0 then
	
		if not DAK:GetLevelSufficient(client, playerId) then
			return
		end
	
		if DAK.config.baseadmincommands.kBanSubmissionURL ~= "" then
			//Submit ban with key, working on logic to hash key
			//Should these be both submitted to database and logged on server?  My thinking is no here, so going with that moving forward.
			//DAK.config.baseadmincommands.kBanSubmissionURL
			//DAK.config.baseadmincommands.kCryptographyKey
			//Will also want ban response function to reload web bans.
			//OnPlayerBannedResponse
			//Shared.SendHTTPRequest(DAK.config.baseadmincommands.kBanSubmissionURL, "POST", parms, OnPlayerBannedResponse)
		else
			LoadBannedPlayers()
			table.insert(bannedPlayers, { name = "Unknown", id = tonumber(playerId), reason = StringConcatArgs(...), time = bannedUntilTime })
			SaveBannedPlayers()
		end
		
		ServerAdminPrint(client, "Player with SteamId " .. playerId .. " has been banned.")
		DAK:PrintToAllAdmins("sv_ban", client, string.format("on SteamID:%s for %s for %s.", playerId, duration, args))
		
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_ban", Ban, "<player id> <duration in minutes> <reason text> Bans the player from the server, pass in 0 for duration to ban forever")

local function UnBan(client, steamId)

	local found = false
	local foundweb = false
	LoadBannedPlayers()
	for p = #bannedPlayers, 1, -1 do
	
		if bannedPlayers[p].id == steamId then
		
			table.remove(bannedPlayers, p)
			ServerAdminPrint(client, "Removed " .. steamId .. " from the ban list.")
			found = true
			
		end
		
	end
	
	for p = #bannedPlayersWeb, 1, -1 do
	
		if bannedPlayersWeb[p].id == steamId then
		
			table.remove(bannedPlayersWeb, p)
			ServerAdminPrint(client, "Removed " .. steamId .. " from the ban list.")
			foundweb = true
			
		end
		
	end
	
	if found then
		DAK:PrintToAllAdmins("sv_unban", client, string.format(" on SteamID:%s.", steamId))
		SaveBannedPlayers()
	end
	
	if foundweb then
		//Submit unban with key
		//DAK.config.baseadmincommands.kUnBanSubmissionURL
		//DAK.config.baseadmincommands.kCryptographyKey
		//OnPlayerUnBannedResponse
		//Shared.SendHTTPRequest(DAK.config.baseadmincommands.kUnBanSubmissionURL, "GET", OnPlayerUnBannedResponse)
	end
	
	if not found and not foundweb then
		ServerAdminPrint(client, "No matching Steam Id in ban list.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_unban", UnBan, "<steam id> Removes the player matching the passed in Steam Id from the ban list")

function GetBannedPlayersList()

	local returnList = { }
	
	for p = 1, #bannedPlayers do
	
		local ban = bannedPlayers[p]
		table.insert(returnList, { name = ban.name, id = ban.id, reason = ban.reason, time = ban.time })
		
	end
	
	return returnList
	
end

local function ListBans(client)

	if #bannedPlayers == 0 and #bannedPlayersWeb == 0 then
		ServerAdminPrint(client, "No players are currently banned.")
	end
	
	for p = 1, #bannedPlayers do
	
		local ban = bannedPlayers[p]
		local timeLeft = ban.time == 0 and "Forever" or (((ban.time - Shared.GetSystemTime()) / 60) .. " minutes")
		ServerAdminPrint(client, "Name: " .. ban.name .. " Id: " .. ban.id .. " Time Remaining: " .. timeLeft .. " Reason: " .. (ban.reason or "Not provided"))
		
	end
	
	for p = 1, #bannedPlayersWeb do
	
		local ban = bannedPlayersWeb[p]
		local timeLeft = ban.time == 0 and "Forever" or (((ban.time - Shared.GetSystemTime()) / 60) .. " minutes")
		ServerAdminPrint(client, "Name: " .. ban.name .. " Id: " .. ban.id .. " Time Remaining: " .. timeLeft .. " Reason: " .. (ban.reason or "Not provided"))
		
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_listbans", ListBans, "Lists the banned players")

local function UpdateNick(client, playerId, nick)

    local player = DAK:GetPlayerMatching(playerId)
	
    if player and nick ~= nil then
		local oldname = player:GetName()
        player:SetName(nick)
		ServerAdminPrint(client, string.format("Player's name was changed from %s to %s.", oldname, player:GetName()))
		DAK:PrintToAllAdmins("sv_nick", client, string.format(" on %s to %s.", oldname, player:GetName()))
    else
        ServerAdminPrint(client, "No matching player.")
    end
    
end

DAK:CreateServerAdminCommand("Console_sv_nick", UpdateNick, "<player id> <name> Changes name of the provided player.")

local kChatsPerSecondAdded = DAK.config.baseadmincommands.ChatRecoverRate
local kMaxChatsInBucket = DAK.config.baseadmincommands.ChatLimit
local function CheckChatAllowed(client)

	client.chatTokenBucket = client.chatTokenBucket or CreateTokenBucket(kChatsPerSecondAdded, kMaxChatsInBucket)
	// Returns true if there was a token to remove.
	return client.chatTokenBucket:RemoveTokens(1)
	
end

local function GetChatPlayerData(client)

	local playerName = "Admin"
	local playerLocationId = -1
	local playerTeamNumber = kTeamReadyRoom
	local playerTeamType = kNeutralTeamType
	
	if client then
	
		local player = client:GetControllingPlayer()
		if not player then
			return
		end
		playerName = player:GetName()
		playerLocationId = player.locationId
		playerTeamNumber = player:GetTeamNumber()
		playerTeamType = player:GetTeamType()
		
	end
	
	return playerName, playerLocationId, playerTeamNumber, playerTeamType
	
end

local function OnChatReceived(client, message)

	if not CheckChatAllowed(client) then
		return
	end
	
	chatMessage = string.sub(message.message, 1, kMaxChatLength)
	
	if DAK:IsClientGagged(client) then
		chatMessage = DAK.config.baseadmincommands.GaggedClientMessage
	end
	
	if chatMessage and string.len(chatMessage) > 0 then
	
		local playerName, playerLocationId, playerTeamNumber, playerTeamType = GetChatPlayerData(client)
		
		if playerName then
		
			if message.teamOnly then
			
				local players = GetEntitiesForTeam("Player", playerTeamNumber)
				for index, player in ipairs(players) do
					Server.SendNetworkMessage(player, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
				end
				
			else
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
			end
			
			Shared.Message("Chat " .. (message.teamOnly and "Team - " or "All - ") .. playerName .. ": " .. chatMessage)
			
			// We save a history of chat messages received on the Server.
			Server.AddChatToHistory(chatMessage, playerName, client:GetUserId(), playerTeamNumber, message.teamOnly)
			
		end
		
	end
	
end

local function DelayedEventHooks()
	DAK:ReplaceNetworkMessageFunction("ChatClient", OnChatReceived)
end

DAK:RegisterEventHook("OnPluginInitialized", DelayedEventHooks, 5)

local function OnCommandGagPlayer(client, playerId, duration)

	local player = DAK:GetPlayerMatching(playerId)
	duration = tonumber(duration)
	if duration == nil then 
		duration = DAK.config.baseadmincommands.DefaultGagTime * 60
	else
		duration = duration * 60
	end
	
	if player and duration ~= nil then
		local targetclient = Server.GetOwner(player)
		if targetclient then
			DAK:AddClientToGaggedList(targetclient, duration)
			DAK:DisplayMessageToClient(targetclient, "GaggedMessage")
			ServerAdminPrint(client, string.format("Player %s was gagged for %.1f minutes.", player:GetName(), (duration / 60)))
			DAK:PrintToAllAdmins("sv_gag", client, string.format("Player %s was gagged for %.1f minutes.", player:GetName(), (duration / 60)))
		end
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_gag", OnCommandGagPlayer, "<player id> <duration> Gags the provided player for the provided minutes.")

local function OnCommandUnGagPlayer(client, playerId)

	local player = DAK:GetPlayerMatching(playerId)
	
	if player then
		local targetclient = Server.GetOwner(player)
		if targetclient then
			DAK:RemoveClientFromGaggedList(targetclient)
			DAK:DisplayMessageToClient(targetclient, "UngaggedMessage")
			ServerAdminPrint(client, string.format("Player %s was ungagged.", player:GetName()))
			DAK:PrintToAllAdmins("sv_gag", client, string.format("Player %s was ungagged.", player:GetName()))
		end
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_ungag", OnCommandUnGagPlayer, "<player id> Ungags the provided player.")