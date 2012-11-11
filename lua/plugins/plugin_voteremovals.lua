//NS2 Player Removal Votes

local kRemovalVoteArray = { }
local kRemovalTarget = nil
local kRemovalVoteRunning = 0
local kRemovalVoteAlertTime = 0

if kDAKConfig and kDAKConfig.VoteRemovals and kDAKConfig.VoteRemovals.kEnabled then

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

	local function GetPlayerMatchingSteamId(steamId)

		assert(type(steamId) == "number")
		local match = nil
		local function Matches(player)
			local playerClient = Server.GetOwner(player)
			if playerClient and playerClient:GetUserId() == steamId then
				match = player
			end
		end
		AllPlayers(Matches)()
		return match
		
	end

	local function GetPlayerMatchingName(name)

		assert(type(name) == "string")
		local match = nil
		local function Matches(player)
			if player:GetName() == name then
				match = player
			end
		end
		AllPlayers(Matches)()
		return match
		
	end

	local function GetPlayerMatching(id)

		local idNum = tonumber(id)
		if idNum then
			return GetPlayerMatchingGameId(idNum) or GetPlayerMatchingSteamId(idNum)
		elseif type(id) == "string" then
			return GetPlayerMatchingName(id)
		end
			
	end

	local function UpdateRemovalVotes()

		if kRemovalVoteRunning ~= 0 and kRemovalVoteAlertTime + kDAKConfig.VoteRemovals.kVoteRemovalAlertDelay < Shared.GetTime() then
			//Check that player is still valid
			if kRemovalTarget == nil or VerifyClient(kRemovalTarget) == nil then
				//Invalidate vote
				chatMessage = string.sub(string.format("The removal vote for your player %s has expired.", kRemovalTarget), 1, kMaxChatLength)
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Team - Admin", -1, i, kNeutralTeamType, chatMessage), true)
				kRemovalVoteAlertTime = 0
				kRemovalVoteRunning = 0
				kRemovalTarget = nil
				kRemovalVoteArray = { }
				return
			end
			local playerRecords = Shared.GetEntitiesWithClassname("Player")
			local totalvotes = 0
			for j = #kRemovalVoteArray, 1, -1 do
				local clientid = kRemovalVoteArray
				local stillplaying = false
			
				for k = 1, #playerRecords do
					local player = playerRecords[k]
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
					table.remove(kRemovalVoteArray, j)
				end
			
			end
			if totalvotes >= math.ceil((#playerRecords * (kDAKConfig.VoteRemovals.kVoteRemovalMinimumPercentage / 100))) then
		
				chatMessage = string.sub(string.format("Vote to removal player %s has passed", kRemovalTarget), 1, kMaxChatLength)
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
				//Kick that bad boy
				
			else
				local chatmessage
				if kRemovalVoteAlertTime == 0 then
					chatMessage = string.sub(string.format("A vote to remove player %s has started. %s votes are needed.", kRemovalTarget, 
					 math.ceil((#playerRecords * (kDAKConfig.VoteRemovals.kVoteRemovalMinimumPercentage / 100))) ), 1, kMaxChatLength)
					kRemovalVoteAlertTime = Shared.GetTime()
				elseif kRemovalVoteRunning + kDAKConfig.VoteRemovals.kVoteRemovalVotingTime < Shared.GetTime() then
					chatMessage = string.sub(string.format("The removal vote for your player %s has expired.", kRemovalTarget), 1, kMaxChatLength)
					kRemovalVoteAlertTime = 0
					kRemovalVoteRunning = 0
					kRemovalTarget = nil
					kRemovalVoteArray = { }
				else
					chatMessage = string.sub(string.format("%s votes to remove player %s, %s needed, %s seconds left. type remove to vote", totalvotes, 
					 math.ceil((#playerRecords * (kDAKConfig.VoteRemovals.kVoteRemovalMinimumPercentage / 100))), 
					 math.ceil((kRemovalVoteRunning + kDAKConfig.VoteRemovals.kVoteRemovalVotingTime) - Shared.GetTime()) ), 1, kMaxChatLength)
					kRemovalVoteAlertTime = Shared.GetTime()
				end
				Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Team - Admin", -1, i, kNeutralTeamType, chatMessage), true)
			end
			
		end
			
	end
	
	table.insert(kDAKOnServerUpdate, function(deltatime) return UpdateRemovalVotes() end)

	local function OnCommandVoteRemove(client, parm1)
		
		local removalplayer
		if parm1 ~= nil then
			removalplayer = GetPlayerMatching(parm1)
		end
		if client ~= nil then
			local player = client:GetControllingPlayer()
			local clientID = client:GetUserId()
			if player ~= nil and clientID ~= nil then
				if kRemovalVoteRunning ~= 0 then
					local alreadyvoted = false
					for i = #kRemovalVoteArray, 1, -1 do
						if kRemovalVoteArray[i] == clientID then
							alreadyvoted = true
							break
						end
					end
					if alreadyvoted then
						chatMessage = string.sub(string.format("You already voted for to remove this player."), 1, kMaxChatLength)
						Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "PM - Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
					else
						chatMessage = string.sub(string.format("You have voted to remove this player."), 1, kMaxChatLength)
						Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "PM - Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
						table.insert(kRemovalVoteArray, clientID)
					end						
				elseif removalplayer ~= nil then
					chatMessage = string.sub(string.format("You have voted to remove this player."), 1, kMaxChatLength)
					Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "PM - Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
					kRemovalVoteRunning = Shared.GetTime()
					kRemovalTarget = Server.GetOwner(removalplayer)
					table.insert(kRemovalVoteArray, clientID)
				end
			end
		end
		
	end

	Event.Hook("Console_remove",               OnCommandVoteRemove)
	
	local function OnVoteRemoveChatMessage(message, playerName, steamId, teamNumber, teamOnly, client)
	
		if client and steamId and steamId ~= 0 then
			if message == "remove" then
				OnCommandVoteRemove(client)	
			end
		end
	
	end
	
	table.insert(kDAKOnClientChatMessage, function(message, playerName, steamId, teamNumber, teamOnly, client) return OnVoteRemoveChatMessage(message, playerName, steamId, teamNumber, teamOnly, client) end)

	local function VoteRemovalOff(client)
	
		if kRemovalVoteRunning ~= 0 then
			kRemovalVoteAlertTime = 0
			kRemovalVoteRunning = 0
			kRemovalVoteArray = { }
			chatMessage = string.sub(string.format("Removal vote for player %s has been cancelled.", kRemovalTarget), 1, kMaxChatLength)
			Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, tmNum, kNeutralTeamType, chatMessage), true)
			kRemovalTarget = nil
			if client ~= nil then 
				ServerAdminPrint(client, string.format("Removal vote for player %s has been cancelled.", kRemovalTarget))
				local player = client:GetControllingPlayer()
				if player ~= nil then
					PrintToAllAdmins("sv_cancelremovalvote", client)
				end
			end
		end

	end

	DAKCreateServerAdminCommand("Console_sv_cancelremovalvote", VoteRemovalOff, "Cancelles a currently running removal vote.")

	local function VoteRemovalOn(client, parm1)
	
		local removalplayer
		if parm1 ~= nil then
			removalplayer = GetPlayerMatching(parm1)
		end
		if kRemovalVoteRunning == 0 and removalplayer then
			kRemovalTarget = Server.GetOwner(removalplayer)
			kRemovalVoteRunning = Shared.GetTime()
			if client ~= nil then
				kRemovalTarget = thing
				ServerAdminPrint(client, string.format("Removal vote started for player %s.", ToString(kRemovalTarget)))
				local player = client:GetControllingPlayer()
				if player ~= nil then
					PrintToAllAdmins("sv_removalvote", client, teamnum)
				end
			end
		end

	end

	DAKCreateServerAdminCommand("Console_sv_removalvote", VoteRemovalOn, "<player> Will start a removal vote for that player.")
	
elseif kDAKConfig and not kDAKConfig.VoteRemovals then
	
	DAKGenerateDefaultDAKConfig("VoteRemovals")

end

Shared.Message("VoteRemovals Loading Complete")