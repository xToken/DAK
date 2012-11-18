//NS2 Client Messages

if kDAKConfig and kDAKConfig.Messages and kDAKConfig.Messages.kEnabled then
      
	local lastMessageTime = 0
	local messageline = 0
	local messagetick = 0
	
	local function DisplayMessage(client, message)

		local player = client:GetControllingPlayer()
		chatMessage = string.sub(string.format(message), 1, kMaxChatLength)
		Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, "", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)

	end
	
	local function ProcessMessagesforUser(client, messagestart)
		
		for i = messagestart, #kDAKConfig.Messages.kMessage do
		
			if i < kDAKConfig.Messages.kMessagesPerTick + messagestart then
				DisplayMessage(client, kDAKConfig.Messages.kMessage[i])
			else
				messagetick = Shared.GetTime() + kDAKConfig.Messages.kMessageTickDelay
				messageline = i
				return
			end
			
		end

		messagetick = 0
		messageline = 0

	end

	local function ProcessMessageQueue(deltatime)

		PROFILE("Messages:ProcessMessageQueue")

		local tt = Shared.GetTime()
		if lastMessageTime + (kDAKConfig.Messages.kMessageInterval * 60) < tt and messagetick < tt then
		
			local oldmessageline = ConditionalValue(messageline > 0, messageline, 1)
			for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
				local client = Server.GetOwner(player)
				
				if client ~= nil and VerifyClient(client) ~= nil then
					ProcessMessagesforUser(client, oldmessageline)
				end
				
			end
			if messageline == 0 then
				lastMessageTime = Shared.GetTime()
			end
			
		end
		return true
		
	end

	table.insert(kDAKOnServerUpdate, function(deltatime) return ProcessMessageQueue(deltatime) end)
	
elseif kDAKConfig and not kDAKConfig.Messages then
	
	DAKGenerateDefaultDAKConfig("Messages")
	
end

Shared.Message("Messages Loading Complete")