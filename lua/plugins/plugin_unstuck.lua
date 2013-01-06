//NS2 Unstuck Plugin

if kDAKConfig and kDAKConfig.Unstuck then

	local UnstuckClientTracker = { }
	local LastUnstuckTracker = { }

	local function DisplayMessage(client, message)

		local player = client:GetControllingPlayer()
		chatMessage = string.sub(string.format(message), 1, kMaxChatLength)
		Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "PM - " .. kDAKConfig.DAKLoader.MessageSender, -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)

	end
	
	local function UnstuckClient(client, player, PEntry)

		if PEntry.Orig ~= player:GetOrigin() then
			DisplayMessage(client, string.format("You moved since issuing unstuck command?"))
		else
			local TechID = kTechId.Skulk
			if player:GetIsAlive() then
				TechID = player:GetTechId()
			end
			PEntry.Orig.x = PEntry.Orig.x + kDAKConfig.Unstuck.kUnstuckAmount
			PEntry.Orig.z = PEntry.Orig.z + kDAKConfig.Unstuck.kUnstuckAmount
			local extents = LookupTechData(TechID, kTechDataMaxExtents)
			local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
			local range = 6
			for t = 1, 100 do //Persistance...
				local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, PEntry.Orig, 2, range, EntityFilterAll())
				if spawnPoint then
					local validForPlayer = GetIsPlacementForTechId(spawnPoint, true, TechID)
					local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) == 0
					if notNearResourcePoint then
						SpawnPlayerAtPoint(player, spawnPoint)
						break
					end
				end
			end
			DisplayMessage(client, string.format("Unstuck!"))
		end

	end
	
	local function RegisterClientStuck(client)
		if client ~= nil then
			
			local ID = client:GetUserId()
			if LastUnstuckTracker[ID] == nil or LastUnstuckTracker[ID] + kDAKConfig.Unstuck.kTimeBetweenUntucks < Shared.GetTime() then
				local player = client:GetControllingPlayer()
				local PEntry = { ID = client:GetUserId(), Orig = player:GetOrigin(), Time = Shared.GetTime() + kDAKConfig.Unstuck.kMinimumWaitTime }
				DisplayMessage(client, string.format("You will be unstuck in %s seconds", kDAKConfig.Unstuck.kMinimumWaitTime))
				table.insert(UnstuckClientTracker, PEntry)
			else
				DisplayMessage(client, string.format("You have unstucked to recently, please wait %.1f seconds", (LastUnstuckTracker[ID] + kDAKConfig.Unstuck.kTimeBetweenUntucks) - Shared.GetTime()))
			end
		end
	end
	
	Event.Hook("Console_stuck",               RegisterClientStuck)
	Event.Hook("Console_unstuck",               RegisterClientStuck)
	
	local function OnUnstuckChatMessage(message, playerName, steamId, teamNumber, teamOnly, client)
	
		if client and steamId and steamId ~= 0 then
			for c = 1, #kDAKConfig.Unstuck.kUnstuckChatCommands do
				local chatcommand = kDAKConfig.Unstuck.kUnstuckChatCommands[c]
				if message == chatcommand then
					RegisterClientStuck(client)
				end
			end
		end
	
	end
	
	table.insert(kDAKOnClientChatMessage, function(message, playerName, steamId, teamNumber, teamOnly, client) return OnUnstuckChatMessage(message, playerName, steamId, teamNumber, teamOnly, client) end)

	local function ProcessStuckUsers(deltatime)

		PROFILE("Unstuck:ProcessStuckUsers")

		if #UnstuckClientTracker > 0 then
			local playerRecords = Shared.GetEntitiesWithClassname("Player")
			for i = #UnstuckClientTracker, 1, -1 do
				local PEntry = UnstuckClientTracker[i]
				if PEntry ~= nil then
					if PEntry.Time and PEntry.Time < Shared.GetTime() then
						for _, player in ientitylist(playerRecords) do
							if player ~= nil then
								local client = Server.GetOwner(player)
								if client ~= nil then
									if PEntry.ID == client:GetUserId() then
										//Client still active, unstuck them
										UnstuckClient(client, player, PEntry)
										LastUnstuckTracker[PEntry.ID] = Shared.GetTime()
										UnstuckClientTracker[i] = nil
									end
								else
									UnstuckClientTracker[i] = nil
								end
							else
								UnstuckClientTracker[i] = nil
							end
						end
					end
				else
					UnstuckClientTracker[i] = nil
				end
			end
		end
		return true
	end

	DAKRegisterEventHook(kDAKOnServerUpdate, function(deltatime) return ProcessStuckUsers(deltatime) end, 5)
	
end

Shared.Message("Unstuck Loading Complete")