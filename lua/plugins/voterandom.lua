//NS2 Vote Random Teams

local kVoteRandomTeamsEnabled
local RandomNewRoundDelay = 10
local RandomVotes = { }
local RandomVoteStart = 0
local LastRandomVote = 0
local RandomDuration = 0
local RandomRoundRecentlyEnded = 0

function RandomTeamsEnabled()
	return kVoteRandomTeamsEnabled
end

function UpdateRandomTeamsState(newstate)
	kVoteRandomTeamsEnabled = (newstate == true) or false
end

local function UpdateRandomStatus()
	UpdateRandomTeamsState((DAK.settings.RandomEnabledTill ~= 0 and DAK.settings.RandomEnabledTill > Shared.GetSystemTime()) or DAK.config.voterandom.kVoteRandomAlwaysEnabled)
end

local function LoadVoteRandom()

	if DAK.settings.RandomEnabledTill == nil then
		DAK.settings.RandomEnabledTill = 0
	end
	UpdateRandomStatus()
	if RandomTeamsEnabled() then
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
			if gamerules then //and not DAK:GetClientCanRunCommand(client, "sv_dontrandom") then
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

local function UpdateRandomTeams()
	UpdateRandomStatus()
	if RandomTeamsEnabled() and not DAK.config.voterandom.kVoteRandomOnGameStart then
		RandomRoundRecentlyEnded = 0
		ShuffleTeams()
	end
	return false
end

local function EnableRandomTeams()
	if DAK.config.voterandom.kVoteRandomInstantly then
		DAK:DisplayMessageToAllClients("VoteRandomEnabled")
		Shared.ConsoleCommand("sv_rrall")
		Shared.ConsoleCommand("sv_reset")
		ShuffleTeams()
	else
		DAK:DisplayMessageToAllClients("VoteRandomEnabledDuration", DAK.config.voterandom.kVoteRandomDuration)
		DAK.settings.RandomEnabledTill = Shared.GetSystemTime() + (DAK.config.voterandom.kVoteRandomDuration * 60)
		DAK:SaveSettings()
		UpdateRandomTeamsState(true)
		UpdateRandomTeams()
	end
end

local function EndRandomVote()
	LastRandomVote = Shared.GetTime()
	RandomVoteStart = 0
	RandomVotes = { }
end

local function VoteRandomSetGameState(self, state, currentstate)

	if state ~= currentstate and state == kGameState.Started and DAK.config.voterandom.kVoteRandomOnGameStart then
		ShuffleTeams()
	end
	
end

DAK:RegisterEventHook("OnSetGameState", VoteRandomSetGameState, 5, "voterandom")

local function GetCurrentRandomVotes()
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
	return totalvotes
end

local function UpdateRandomVotes(silent, playername)
	local playerRecords = Shared.GetEntitiesWithClassname("Player")
	local totalvotes = GetCurrentRandomVotes()
	
	if totalvotes >= math.ceil((playerRecords:GetSize() * (DAK.config.voterandom.kVoteRandomMinimumPercentage / 100))) then
	
		EnableRandomTeams()
		EndRandomVote()
		
	elseif not silent then
	
		DAK:DisplayLegacyChatMessageToAllClientWithoutMenus("VoteRandomVoteCountAlert", playername, totalvotes, math.ceil((playerRecords:GetSize() * (DAK.config.voterandom.kVoteRandomMinimumPercentage / 100))))
		
	end
	
end

DAK:RegisterEventHook("OnClientDisconnect", UpdateRandomVotes, 5, "voterandom")

local function VoteRandomClientConnect(client)

	if client ~= nil and RandomTeamsEnabled() then
		local player = client:GetControllingPlayer()
		if player ~= nil then
			DAK:DisplayMessageToClient(client, "VoteRandomConnectAlert")
			JoinRandomTeam(player)
		end
	end
	
end

DAK:RegisterEventHook("OnClientDelayedConnect", VoteRandomClientConnect, 5, "voterandom")

local function VoteRandomJoinTeam(self, player, newTeamNumber, force)
	if (RandomRoundRecentlyEnded ~= 0 and RandomRoundRecentlyEnded + RandomNewRoundDelay > Shared.GetTime()) and (newTeamNumber == 1 or newTeamNumber == 2) and not DAK.config.voterandom.kVoteRandomOnGameStart then
		DAK:DisplayMessageToClient(Server.GetOwner(player), "VoteRandomTeamJoinBlock")
		return true
	end
end

DAK:RegisterEventHook("OnTeamJoin", VoteRandomJoinTeam, 5, "voterandom")

local function VoteRandomEndGame(self, winningTeam)
	if RandomTeamsEnabled() then
		RandomRoundRecentlyEnded = Shared.GetTime()
		DAK:SetupTimedCallBack(UpdateRandomTeams, RandomNewRoundDelay)
	end
end

DAK:RegisterEventHook("OnGameEnd", VoteRandomEndGame, 5, "voterandom")

local function OnCommandRandomVote(client, selectionnumber, page)
	if selectionnumber == 1 then
		RandomVotes[client:GetUserId()] = true
	else
		return true
	end
end

local function OnCommandUpdateRandomVote(ns2id, LastUpdateMessage, page)
	//OnVoteUpdateFunction
	if RandomVoteStart ~= 0 then
		local kVoteUpdateMessage = DAK:CreateMenuBaseNetworkMessage()
		if kVoteUpdateMessage == nil then
			kVoteUpdateMessage = { }
		end
		local client =  DAK:GetClientMatchingNS2Id(ns2id)
		local playerRecords = Shared.GetEntitiesWithClassname("Player")
		local totalvotes = GetCurrentRandomVotes()
		kVoteUpdateMessage.header = string.format("%s votes, %s required to enable random teams.", totalvotes, math.ceil((playerRecords:GetSize() * (DAK.config.voterandom.kVoteRandomMinimumPercentage / 100))))
		if RandomVotes[client:GetUserId()] == true then
			kVoteUpdateMessage.option[1] = "You have voted to enable random teams."
		else
			kVoteUpdateMessage.option[1] = "Vote to enable random teams."
			kVoteUpdateMessage.option[2] = "Vote to not random teams."
		end
		kVoteUpdateMessage.inputallowed = true
		kVoteUpdateMessage.footer = "Press a number key to vote on random teams."
		return kVoteUpdateMessage
	else
		return LastUpdateMessage
	end
end

local function OnCommandVoteRandom(client)

	if client ~= nil then
		local ns2id = client:GetUserId()
		local player = client:GetControllingPlayer()
		if player ~= nil then
			if RandomTeamsEnabled() then
				DAK:DisplayMessageToClient(client, "VoteRandomAlreadyEnabled")
				return
			end
			if LastRandomVote ~= 0 and LastRandomVote >= (Shared.GetTime() - DAK.config.voterandom.kTimeBetweenVotes) then
				DAK:DisplayMessageToClient(client, "VoteRandomMinimumDuration")
				return
			end
			if RandomVoteStart == 0 then
				DAK:SetupTimedCallBack(EndRandomVote, DAK.config.voterandom.kVotingDuration)
				RandomVoteStart = Shared.GetTime()
				//Start GUI!!!
				DAK:ForAllPlayers(function (plyr)
					DAK:CreateGUIMenuBase(DAK:GetNS2IdMatchingPlayer(plyr), OnCommandRandomVote, OnCommandUpdateRandomVote, false)
				end)
			end
			if RandomVotes[ns2id] ~= nil then			
				DAK:DisplayMessageToClient(client, "VoteRandomAlreadyVoted")
			else
				table.insert(RandomVotes,ns2id)
				RandomVotes[ns2id] = true
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

	if RandomTeamsEnabled() then
		UpdateRandomTeamsState(false)
		DAK.settings.RandomEnabledTill = 0
		DAK:SaveSettings()
		DAK:DisplayMessageToAllClients("VoteRandomDisabled")
		DAK:PrintToAllAdmins("sv_randomoff", client)
		ServerAdminPrint(client, "Random teams have been disabled.")
	else
		ServerAdminPrint(client, "Random teams were not enabled.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_randomoff", VoteRandomOff, "Turns off any currently active random teams vote.")

local function VoteRandomOn(client)

	if not RandomTeamsEnabled() then
		EnableRandomTeams()
		DAK:PrintToAllAdmins("sv_randomon", client)
		ServerAdminPrint(client, "Random teams have been enabled.")
	else
		ServerAdminPrint(client, "Random teams are already enabled.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_randomon", VoteRandomOn, "Will enable random teams.")

local function CancelRandom(client)

	if RandomVoteStart ~= 0 then
		EndRandomVote()
		DAK:PrintToAllAdmins("sv_cancelrandom", client)
		ServerAdminPrint(client, "Random team vote has been cancelled.")
	else
		ServerAdminPrint(client, "No random teams vote in progress.")
	end
	
end

DAK:CreateServerAdminCommand("Console_sv_cancelrandom", CancelRandom, "Will cancel random teams vote.")