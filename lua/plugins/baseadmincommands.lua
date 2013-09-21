//Base Admin Commands
//This is designed to replace the base admin commands.

local function PrintStatus(client)
	DAK:ForAllPlayers(function (player, client)
		local playerClient = Server.GetOwner(player)
		if not playerClient then
			Shared.Message("playerClient is nil in PrintStatus, alert Brian")
		else
			local playerId = playerClient:GetUserId()
			if DAK:GetClientCanRunCommand(client, "sv_status") then
				local playerAddressString = IPAddressToString(Server.GetClientAddress(playerClient))
				ServerAdminPrint(client, player:GetName() .. " : Game Id = " 
				.. ToString(DAK:GetGameIdMatchingClient(playerClient))
				.. " : NS2 Id = " .. playerId
				.. " : Steam Id = " .. DAK:GetSteamIdfromNS2ID(playerId)
				.. " : Team = " .. player:GetTeamNumber()
				.. " : Address = " .. playerAddressString
				.. " : Connection Time = " .. DAK:GetClientConnectionTime(playerClient))
			else
				ServerAdminPrint(client, player:GetName() .. " : Game Id = " 
				.. ToString(DAK:GetGameIdMatchingClient(playerClient))
				.. " : NS2 Id = " .. playerId
				.. " : Steam Id = " .. DAK:GetSteamIdfromNS2ID(playerId)
				.. " : Team = " .. player:GetTeamNumber())
			end

		end
	end, client)
end

DAK:CreateServerAdminCommand("Console_sv_status", PrintStatus, "Lists player Ids and names for use in sv commands", true)

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
	local playerList = DAK:GetPlayerList()
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
	DAK:PrintToAllAdmins("sv_password", client, newPassword or "")		
end

DAK:CreateServerAdminCommand("Console_sv_password", SetPassword, "<string> Changes the password on the server")

local function SetCheats(client, enabled)
    Shared.ConsoleCommand("cheats " .. ((enabled == "true" or enabled == "1") and "1" or "0"))
end

DAK:CreateServerAdminCommand("Console_sv_cheats", SetCheats, "<boolean>, Turns cheats on and off")

local function Ban(client, playerId, name, duration, ...)

	local player = DAK:GetPlayerMatching(playerId)
	local reason =  StringConcatArgs(...) or "No Reason"
	local ns2Id = DAK:GetNS2IDFromSteamID(playerId)
	local adminns2Id = DAK:GetNS2IdMatchingClient(client)
	if tonumber(name) ~= nil and tonumber(duration) == nil then
		reason = duration or "No Reason"
		if ... ~= nil then
			reason = duration .. " " .. StringConcatArgs(...) or "No Reason"
		end
		duration = name
		if player then
			name = player:GetName()
		else
			name = "Not Provided"
		end
	end
	duration = tonumber(duration) or 0
	if player then
		if not DAK:GetLevelSufficient(client, player) then
			return
		end
		local bannedclient = Server.GetOwner(player)
		if bannedclient then
			if DAK:AddNS2IDBan(bannedclient:GetUserId(), name or player:GetName(), duration, reason, adminns2Id) then
				ServerAdminPrint(client, player:GetName() .. " has been banned.")
				DAK:PrintToAllAdmins("sv_ban", client, string.format("on %s for %s for %s.", DAK:GetClientUIDString(bannedclient), duration, reason))
				bannedclient.disconnectreason = reason
				Server.DisconnectClient(bannedclient)
			end
		end

	elseif tonumber(playerId) ~= nil or ns2Id ~= nil then
	
		if tonumber(playerId) == nil and ns2Id ~= nil then
			playerId = ns2Id
		end
		if not DAK:GetLevelSufficient(client, playerId) then
			return
		end
		if DAK:AddNS2IDBan(tonumber(playerId), name or "Unknown", duration, reason, adminns2Id) then
			ServerAdminPrint(client, "Player with NS2Id " .. playerId .. " has been banned.")
			DAK:PrintToAllAdmins("sv_ban", client, string.format("on NS2Id:%s for %s for %s.", playerId, duration, reason))
		end
	
	else
		ServerAdminPrint(client, "No matching player.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_ban", Ban, "<player id> <player name> <duration in minutes> <reason text> Bans the player from the server, pass in 0 for duration to ban forever")

local function UnBan(client, playerId)

	local adminns2Id = DAK:GetNS2IdMatchingClient(client)
	if DAK:UnBanNS2ID(playerId, adminns2Id) or DAK:UnBanSteamID(playerId, adminns2Id) then
		DAK:PrintToAllAdmins("sv_unban", client, string.format(" on ID : %s.", playerId))
		ServerAdminPrint(client, "Player with ID " .. playerId .. " has been unbanned.")
	else
		ServerAdminPrint(client, "No matching ID in ban list.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_unban", UnBan, "<ID> Removes the player matching the passed in ID from the ban list")

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

DAK:RegisterEventHook("OnPluginInitialized", DelayedEventHooks, 5, "baseadmincommands")

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

local function PLogAll(client)

    Shared.ConsoleCommand("p_logall")
    ServerAdminPrint(client, "Performance logging enabled")
    
end

DAK:CreateServerAdminCommand("Console_sv_p_logall", PLogAll, "Starts performance logging")

local function PEndLog(client)

    Shared.ConsoleCommand("p_endlog")
    ServerAdminPrint(client, "Performance logging disabled")
    
end

DAK:CreateServerAdminCommand("Console_sv_p_endlog", PEndLog, "Ends performance logging")

local function AutoBalance(client, enabled, playerCount, seconds)

    if enabled == "true" then
    
        playerCount = playerCount and tonumber(playerCount) or 2
        seconds = seconds and tonumber(seconds) or 10
        Server.SetConfigSetting("auto_team_balance", { enabled_on_unbalance_amount = playerCount, enabled_after_seconds = seconds })
        ServerAdminPrint(client, "Auto Team Balance is now Enabled. Player unbalance amount: " .. playerCount .. " Activate delay: " .. seconds)
        
    else
    
        Server.SetConfigSetting("auto_team_balance", nil)
        ServerAdminPrint(client, "Auto Team Balance is now Disabled")
        
    end
    
end

DAK:CreateServerAdminCommand("Console_sv_autobalance", AutoBalance, "<true/false> <player count> <seconds>, Toggles auto team balance. The player count and seconds are optional. Count defaults to 2 over balance to enable. Defaults to 10 second wait to enable.")

local function AutoKickAFK(client, time, capacity)

    time = tonumber(time) or 300
    capacity = tonumber(capacity) or 0.5
    Server.SetConfigSetting("auto_kick_afk_time", time)
    Server.SetConfigSetting("auto_kick_afk_capacity", capacity)
    ServerAdminPrint(client, "Auto-kick AFK players is " .. (time <= 0 and "disabled" or "enabled") .. ". Kick after: " .. math.floor(time) .. " seconds when server is at: " .. math.floor(capacity * 100) .. "% capacity")
    
end

DAK:CreateServerAdminCommand("Console_sv_auto_kick_afk", AutoKickAFK, "<seconds> <number>, Auto-kick is disabled when the first argument is 0. A player will be kicked only when the server is at the defined capacity (0-1).")

local function EnableEventTesting(client, enabled)

    enabled = not (enabled == "false")
    SetEventTestingEnabled(enabled)
    ServerAdminPrint(client, "Event testing " .. (enabled and "enabled" or "disabled"))
    
end

DAK:CreateServerAdminCommand("Console_sv_test_events", EnableEventTesting, "<true/false>, Toggles event testing mode")

//Populate basic DAKMenu
local function OnCommandUpdateBanMenu(ns2id, LastUpdateMessage, page)
	local kVoteUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
	kVoteUpdateMessage.header = string.format("Player to ban.")
	DAK:PopulateClientMenuItemWithClientList(kVoteUpdateMessage, page)
	kVoteUpdateMessage.inputallowed = true
	kVoteUpdateMessage.footer = "DAK Ban Menu"
	return kVoteUpdateMessage
end

local function OnCommandBanSelection(client, selectionnumber, page)
	local targetclient = DAK:GetClientList()[selectionnumber + (page * 8)]
	if targetclient ~= nil then
		local HeadingText = string.format("Please confirm you wish to ban %s?", DAK:GetClientUIDString(targetclient))
		DAK:DisplayConfirmationMenuItem(DAK:GetNS2IdMatchingClient(client), HeadingText, Ban, nil, DAK:GetNS2IdMatchingClient(targetclient))
	end
end

local function OnCommandUpdateKickMenu(ns2id, LastUpdateMessage, page)
	local kVoteUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
	kVoteUpdateMessage.header = string.format("Player to kick.")
	DAK:PopulateClientMenuItemWithClientList(kVoteUpdateMessage, page)
	kVoteUpdateMessage.inputallowed = true
	kVoteUpdateMessage.footer = "DAK Kick Menu"
	return kVoteUpdateMessage
end

local function OnCommandKickSelection(client, selectionnumber, page)
	local targetclient = DAK:GetClientList()[selectionnumber + (page * 8)]
	if targetclient ~= nil then
		local HeadingText = string.format("Please confirm you wish to kick %s?", DAK:GetClientUIDString(targetclient))
		DAK:DisplayConfirmationMenuItem(DAK:GetNS2IdMatchingClient(client), HeadingText, Kick, nil, DAK:GetNS2IdMatchingClient(targetclient))
	end
end

local function OnCommandUpdateSlayMenu(ns2id, LastUpdateMessage, page)
	local kVoteUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
	kVoteUpdateMessage.header = string.format("Player to slay.")
	DAK:PopulateClientMenuItemWithClientList(kVoteUpdateMessage, page)
	kVoteUpdateMessage.inputallowed = true
	kVoteUpdateMessage.footer = "DAK Slay Menu"
	return kVoteUpdateMessage
end

local function OnCommandSlaySelection(client, selectionnumber, page)
	local targetclient = DAK:GetClientList()[selectionnumber + (page * 8)]
	if targetclient ~= nil then
		local HeadingText = string.format("Please confirm you wish to slay %s?", DAK:GetClientUIDString(targetclient))
		DAK:DisplayConfirmationMenuItem(DAK:GetNS2IdMatchingClient(client), HeadingText, Slay, nil, DAK:GetNS2IdMatchingClient(targetclient))
	end
end

local function GetMapName(map)
	if type(map) == "table" and map.map ~= nil then
		return map.map
	end
	return map
end

local function OnCommandUpdateMapsMenu(ns2id, LastUpdateMessage, page)
	local kVoteUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
	kVoteUpdateMessage.header = string.format("What map?")
	local maps = MapCycle_GetMapCycleArray()
	if maps ~= nil then
		for p = 1, #maps do
			local ci = p - (page * 8)
			if ci > 0 and ci < 9 then
				kVoteUpdateMessage.option[ci] = GetMapName(maps[p])
			end
		end
	end
	kVoteUpdateMessage.inputallowed = true
	kVoteUpdateMessage.footer = "DAK Change Map Menu"
	return kVoteUpdateMessage
end

local function OnCommandMapSelection(client, selectionnumber, page)
	local maps = MapCycle_GetMapCycleArray()
	if maps ~= nil then
		local targetmap = GetMapName(maps[selectionnumber + (page * 8)])
		if targetmap ~= nil then
			local HeadingText = string.format("Please confirm you wish to change map to %s?", targetmap)
			DAK:DisplayConfirmationMenuItem(DAK:GetNS2IdMatchingClient(client), HeadingText, OnCommandChangeMap, nil, targetmap)
		end
	end
end

local function GetBansMenu(client)
	DAK:CreateGUIMenuBase(DAK:GetNS2IdMatchingClient(client), OnCommandBanSelection, OnCommandUpdateBanMenu, true)
end

local function GetKickMenu(client)
	DAK:CreateGUIMenuBase(DAK:GetNS2IdMatchingClient(client), OnCommandKickSelection, OnCommandUpdateKickMenu, true)
end

local function GetSlayMenu(client)
	DAK:CreateGUIMenuBase(DAK:GetNS2IdMatchingClient(client), OnCommandSlaySelection, OnCommandUpdateSlayMenu, true)
end

local function GetMapsMenu(client)
	DAK:CreateGUIMenuBase(DAK:GetNS2IdMatchingClient(client), OnCommandMapSelection, OnCommandUpdateMapsMenu, true)
end

DAK:RegisterMainMenuItem("Slay Menu", function(client) return DAK:GetClientCanRunCommand(client, "sv_slay") end, GetSlayMenu)
DAK:RegisterMainMenuItem("Kick Menu", function(client) return DAK:GetClientCanRunCommand(client, "sv_kick") end, GetKickMenu)
DAK:RegisterMainMenuItem("Ban Menu", function(client) return DAK:GetClientCanRunCommand(client, "sv_ban") end, GetBansMenu)
DAK:RegisterMainMenuItem("Maps Menu", function(client) return DAK:GetClientCanRunCommand(client, "sv_changemap") end, GetMapsMenu)

DAK:OverrideScriptLoad("lua/ServerAdminCommands.lua")