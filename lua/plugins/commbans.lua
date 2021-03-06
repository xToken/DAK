//NS2 Commander bans

local CommBans = { }
local CommBansFileName = "config://CommBans.json"

local function LoadCommanderBannedPlayers()
	CommBans = DAK:ConvertFromOldBansFormat(DAK:LoadConfigFile(CommBansFileName)) or { }
end

LoadCommanderBannedPlayers()

local function SaveCommanderBannedPlayers()
	DAK:SaveConfigFile(CommBansFileName, CommBans)
end

local function IsCommBanned(playerId)
	playerId = tostring(playerId)
	if playerId ~= nil then
		local bentry = CommBans[playerId]
		if bentry ~= nil then
			local now = Shared.GetSystemTime()
			if bentry.time == 0 or now < bentry.time then
				return true
			else
				LoadCommanderBannedPlayers()
				CommBans[playerId] = nil
				SaveCommanderBannedPlayers()
			end
		end
	end
	return false
end

local function OnPluginInitialized()

	local originalNS2GRGetPlayerBannedFromCommand
	
	originalNS2GRGetPlayerBannedFromCommand = DAK:Class_ReplaceMethod(DAK.config.loader.GamerulesClassName, "GetPlayerBannedFromCommand", 
		function(self, playerId)

			local banned = false //Innocent until proven guilty
			banned = originalNS2GRGetPlayerBannedFromCommand( self, playerId )
			return banned or IsCommBanned(playerId)
		end
	)
	
end

if DAK.config and DAK.config.loader and DAK.config.loader.GamerulesExtensions then
	DAK:RegisterEventHook("OnPluginInitialized", OnPluginInitialized, 5, "commbans")
end

local function DelayedVoteManagerOverride()	
	if VoteManager ~= nil then
		//UpdateVoteManagerFields
		VoteManager.kMinVotesNeeded = DAK.config.commbans.kMinVotesNeeded
		VoteManager.kTeamVotePercentage = DAK.config.commbans.kTeamVotePercentage
	end
	DAK:DeregisterEventHook("OnServerUpdate", DelayedVoteManagerOverride)
end

DAK:RegisterEventHook("OnServerUpdate", DelayedVoteManagerOverride, 5, "commbans")

local function CommBansCastVoteByPlayer(self, voteTechId, player)
	local commanders = GetEntitiesForTeam("Commander", player:GetTeamNumber())
	if table.count(commanders) >= 1 then
		local targetCommander = commanders[1]
		if targetCommander ~= nil then
			local client = Server.GetOwner(targetCommander)
			if client ~= nil then
				if not DAK:GetLevelSufficient(client, playerId) and DAK:GetClientCanRunCommand(client, "sv_ejectionprotection") then
					return true
				end
			end
		end
	end
end

DAK:RegisterEventHook("OnCastVoteByPlayer", CommBansCastVoteByPlayer, 5, "commbans")

local function OnCommandCommBan(client, playerId, pname, duration, ...)

	local player = DAK:GetPlayerMatching(playerId)
	local bannedUntilTime = Shared.GetSystemTime()
	local ns2Id = DAK:GetNS2IDFromSteamID(playerId)
	duration = tonumber(duration)
	if duration == nil or duration <= 0 then
		bannedUntilTime = 0
	else
		bannedUntilTime = bannedUntilTime + (duration * 60)
	end
	
	if player then
		playerId = Server.GetOwner(player):GetUserId()
		if pname == nil then pname = player:GetName() end
	end
	
	if tonumber(playerId) ~= nil or ns2Id ~= nil then
		if not DAK:GetLevelSufficient(client, playerId) then
			return
		end
		if tonumber(playerId) == nil and ns2Id ~= nil then
			playerId = ns2Id
		end
		local bentry = { name = pname, reason = StringConcatArgs(...), time = bannedUntilTime }
		LoadCommanderBannedPlayers()
		CommBans[tostring(playerId)] = bentry
		SaveCommanderBannedPlayers()
		ServerAdminPrint(client, "Player with ID " .. playerId .. " has been banned from the command chair")
	else
		ServerAdminPrint(client, "No matching player")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_commban", OnCommandCommBan, "<player id> <name> <duration in minutes> <reason text>, Bans the player from commanding, pass in 0 for duration to ban forever")

local function OnCommandUnCommBan(client, playerId)

	playerId = tostring(playerId)
	local ns2Id = DAK:GetNS2IDFromSteamID(playerId)
	if playerId ~= nil then
		LoadCommanderBannedPlayers()
		if CommBans[playerId] ~= nil then
			CommBans[playerId] = nil
			SaveCommanderBannedPlayers()
			ServerAdminPrint(client, "Player with ID " .. playerId .. " has been unbanned from the command chair.")
		elseif CommBans[ns2Id] ~= nil then
			CommBans[ns2Id] = nil
			SaveCommanderBannedPlayers()
			ServerAdminPrint(client, "Player with ID " .. ns2Id .. " has been unbanned from the command chair.")
		else
			ServerAdminPrint(client, "No matching ID in commander ban list")
		end
	end
end

DAK:CreateServerAdminCommand("Console_sv_uncommban", OnCommandUnCommBan, "<player id>, Removes the player matching the passed in ID from the commander ban list")

local function ListCommanderBans(client)

	ServerAdminPrint(client, "Current CommanderBans Listing:")
	for id, entry in pairs(CommBans) do
	
		local timeLeft = entry.time == 0 and "Forever" or (((entry.time - Shared.GetSystemTime()) / 60) .. " minutes")
		ServerAdminPrint(client, "Name: " .. entry.name .. " Id: " .. id .. " Time Remaining: " .. timeLeft .. " Reason: " .. (entry.reason or "Not provided"))
		
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_listcommbans", ListCommanderBans, "Lists the commander banned players")