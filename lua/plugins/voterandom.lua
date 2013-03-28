//NS2 Vote Random Teams

local kVoteRandomTeamsEnabled = false
local RandomNewRoundDelay = 15
local RandomVotes = { }
local RandomDuration = 0
local RandomRoundRecentlyEnded = 0

local function UpdateRandomStatus()
	kVoteRandomTeamsEnabled = DAK.settings.RandomEnabledTill > Shared.GetSystemTime() or DAK.config.voterandom.kVoteRandomAlwaysEnabled
end

local function LoadVoteRandom()

	if DAK.settings.RandomEnabledTill == nil then
		DAK.settings.RandomEnabledTill = 0
	end
	UpdateRandomStatus()
	if kVoteRandomTeamsEnabled then
		DAK:ExecutePluginGlobalFunction("enhancedlogging", EnhancedLogMessage, string.format("RandomTeams enabled"))
	end
	
end

LoadVoteRandom()

local function ShuffleTeams()

	local playersrandomed = 0
	local playerList = DAK:ShuffledPlayerList()
	for i = 1, (#playerList) do
		local teamnum = math.fmod(i,2) + 1
		local client = Server.GetOwner(playerList[i])
		if client ~= nil then
			//Trying just making team decision based on position in array.. two randoms seems to somehow result in similar teams..
			local gamerules = GetGamerules()
			if gamerules and not DAK:GetClientCanRunCommand(client, "sv_dontrandom") then
				if not gamerules:GetCanJoinTeamNumber(teamnum) and gamerules:GetCanJoinTeamNumber(math.fmod(teamnum,2) + 1) then
					teamnum = math.fmod(teamnum,2) + 1						
				end
				gamerules:JoinTeam(playerList[i], teamnum)
				playersrandomed = playersrandomed + 1
			end
		end
	end
	return playersrandomed
	
end

local function OnServerUpdateRandomTeams()
	
	UpdateRandomStatus()
	if kVoteRandomTeamsEnabled then
		if RandomRoundRecentlyEnded + RandomNewRoundDelay < Shared.GetTime() and not DAK.config.voterandom.kVoteRandomOnGameStart then
			ShuffleTeams()
			RandomRoundRecentlyEnded = 0
		end
	else
		DAK:DeregisterEventHook("OnServerUpdate", OnServerUpdateRandomTeams)
	end

end

DAK:RegisterEventHook("OnServerUpdate", OnServerUpdateRandomTeams, 5, "voterandom")

local function ExecuteRandomTeams()
	if DAK.config.voterandom.kVoteRandomInstantly then
		DAK:DisplayMessageToAllClients("VoteRandomEnabled")
		Shared.ConsoleCommand("sv_rrall")
		Shared.ConsoleCommand("sv_reset")
		ShuffleTeams()
	else
		DAK:DisplayMessageToAllClients("VoteRandomEnabledDuration", DAK.config.voterandom.kVoteRandomDuration)
		DAK.settings.RandomEnabledTill = Shared.GetSystemTime() + (DAK.config.voterandom.kVoteRandomDuration * 60)
		DAK:SaveSettings()
		kVoteRandomTeamsEnabled = true
		DAK:RegisterEventHook("OnServerUpdate", OnServerUpdateRandomTeams, 5, "voterandom")
	end
end

local function VoteRandomSetGameState(self, state, currentstate)

	if state ~= currentstate and state == kGameState.Started and DAK.config.voterandom.kVoteRandomOnGameStart then
		ShuffleTeams()
	end
	
end

DAK:RegisterEventHook("OnSetGameState", VoteRandomSetGameState, 5, "voterandom")

local function UpdateRandomVotes(silent, playername)

	local playerRecords = Shared.GetEntitiesWithClassname("Player")
	local totalvotes = 0
	
	for i = #RandomVotes, 1, -1 do
		local clientid = RandomVotes[i]
		local stillplaying = false
		
		for _, player in ientitylist(playerRecords) do
			if player ~= nil then
				local client = Server.GetOwner(player)
				if client ~= nil then
					if clientid == client:GetUserId() then
						stillplaying = true
						totalvotes = totalvotes + 1
						break
					end
				end					
			end
		end
		
		if not stillplaying then
			table.remove(RandomVotes, i)
		end
	
	end
	
	if totalvotes >= math.ceil((playerRecords:GetSize() * (DAK.config.voterandom.kVoteRandomMinimumPercentage / 100))) then
	
		RandomVotes = { }
		ExecuteRandomTeams()
		
	elseif not silent then
	
		DAK:DisplayMessageToAllClients("VoteRandomVoteCountAlert", playername, totalvotes, math.ceil((playerRecords:GetSize() * (DAK.config.voterandom.kVoteRandomMinimumPercentage / 100))))
		
	end
	
end

DAK:RegisterEventHook("OnClientDisconnect", UpdateRandomVotes, 5, "voterandom")

local function VoteRandomClientConnect(client)

	if client ~= nil and kVoteRandomTeamsEnabled then
		local player = client:GetControllingPlayer()
		if player ~= nil then
			DAK:DisplayMessageToClient(client, "VoteRandomConnectAlert")
			JoinRandomTeam(player)
		end
	end
	
end

DAK:RegisterEventHook("OnClientDelayedConnect", VoteRandomClientConnect, 5, "voterandom")

local function VoteRandomJoinTeam(self, player, newTeamNumber, force)
	if RandomRoundRecentlyEnded + RandomNewRoundDelay > Shared.GetTime() and (newTeamNumber == 1 or newTeamNumber == 2) and not DAK.config.voterandom.kVoteRandomOnGameStart then
		DAK:DisplayMessageToClient(Server.GetOwner(player), "VoteRandomTeamJoinBlock")
		return true
	end
end

DAK:RegisterEventHook("OnTeamJoin", VoteRandomJoinTeam, 5, "voterandom")

local function VoteRandomEndGame(self, winningTeam)
	if kVoteRandomTeamsEnabled then
		RandomRoundRecentlyEnded = Shared.GetTime()
	end
end

DAK:RegisterEventHook("OnGameEnd", VoteRandomEndGame, 5, "voterandom")

local function OnCommandVoteRandom(client)

	if client ~= nil then
	
		local player = client:GetControllingPlayer()
		if player ~= nil then
			if kVoteRandomTeamsEnabled then
				DAK:DisplayMessageToClient(client, "VoteRandomAlreadyEnabled")
				return
			end
			if RandomVotes[client:GetUserId()] ~= nil then			
				DAK:DisplayMessageToClient(client, "VoteRandomAlreadyVoted")
			else
				table.insert(RandomVotes,client:GetUserId())
				RandomVotes[client:GetUserId()] = true
				Shared.Message(string.format("%s voted for random teams.", DAK:GetClientUIDString(client)))
				DAK:ExecutePluginGlobalFunction("enhancedlogging", EnhancedLogMessage, string.format("%s voted for random teams.", DAK:GetClientUIDString(client)))
				UpdateRandomVotes(false, player:GetName())
			end
		end
		
	end
	
end

Event.Hook("Console_voterandom",               OnCommandVoteRandom)
Event.Hook("Console_random",               OnCommandVoteRandom)

DAK:RegisterChatCommand(DAK.config.voterandom.kVoteRandomChatCommands, OnCommandVoteRandom, false)

local function VoteRandomOff(client)

	if kVoteRandomTeamsEnabled then
		kVoteRandomTeamsEnabled = false
		DAK.settings.RandomEnabledTill = 0
		DAK:SaveSettings()
		DAK:DisplayMessageToAllClients("VoteRandomDisabled")
		DAK:PrintToAllAdmins("sv_randomoff", client)
		ServerAdminPrint(client, "Random teams have been disabled.")
	end
	ServerAdminPrint(client, "Random teams were not enabled.")
	
end

DAK:CreateServerAdminCommand("Console_sv_randomoff", VoteRandomOff, "Turns off any currently active random teams vote.")

local function VoteRandomOn(client)

	if not kVoteRandomTeamsEnabled then
		ExecuteRandomTeams()
		DAK:PrintToAllAdmins("sv_randomon", client)
		ServerAdminPrint(client, "Random teams have been enabled.")
	end
	ServerAdminPrint(client, "Random teams are already enabled.")
	
end

DAK:CreateServerAdminCommand("Console_sv_randomon", VoteRandomOn, "Will enable random teams.")