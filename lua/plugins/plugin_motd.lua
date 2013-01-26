//NS2 Client Message of the Day

local MOTDClientTracker = { }

if kDAKSettings.MOTDAcceptedClients == nil then
	kDAKSettings.MOTDAcceptedClients = { }
end
   
local function DisplayMOTDMessage(client, message)

	local player = client:GetControllingPlayer()
	chatMessage = string.sub(string.format(message), 1, kMaxChatLength)
	Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, kDAKConfig.DAKLoader.MessageSender, -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)

end

local function IsAcceptedClient(client)
	if client ~= nil then
	
		for r = #kDAKSettings.MOTDAcceptedClients, 1, -1 do
			local AcceptedClient = kDAKSettings.MOTDAcceptedClients[r]
			local steamid = client:GetUserId()
			if tonumber(steamid) == nil then return false end
			if AcceptedClient.id == tonumber(steamid) and AcceptedClient.revision == kDAKConfig.MOTD.kMOTDMessageRevision then
				return true
			end
		end
	end
	return false
end

local function ProcessMessagesforUser(PEntry)
	
	local messages = DAKGetLanguageSpecificMessage("kMOTDMessage", DAKGetClientLanguageSetting(client))
	local messagestart = PEntry.Message
	if messages ~= nil then
		for i = messagestart, #messages do
		
			if i < kDAKConfig.MOTD.kMOTDMessagesPerTick + messagestart then
				DisplayMOTDMessage(PEntry.Client, messages[i])
			else
				PEntry.Message = i
				PEntry.Time = Shared.GetTime() + kDAKConfig.MOTD.kMOTDMessageDelay
				break
			end
			
		end
		if #messages < messagestart + kDAKConfig.MOTD.kMOTDMessagesPerTick then
			PEntry = nil
		end
	else
		PEntry = nil
	end
	return PEntry
end

local function MOTDOnClientDisconnect(client)    

	if #MOTDClientTracker > 0 then
		for i = 1, #MOTDClientTracker do
			local PEntry = MOTDClientTracker[i]
			if PEntry ~= nil and PEntry.Client ~= nil and VerifyClient(PEntry.Client) ~= nil then
				if client == PEntry.Client then
					MOTDClientTracker[i] = nil
					break
				end
			end
		end		
	end

end

DAKRegisterEventHook("kDAKOnClientDisconnect", MOTDOnClientDisconnect, 5)

local function ProcessRemainingMOTDMessages(deltatime)

	if #MOTDClientTracker > 0 then
		
		for i = 1, #MOTDClientTracker do
			local PEntry = MOTDClientTracker[i]
			if PEntry ~= nil then
				if PEntry.Client ~= nil and VerifyClient(PEntry.Client) ~= nil then
					if PEntry.Time < Shared.GetTime() then
						MOTDClientTracker[i] = ProcessMessagesforUser(PEntry)
					end
				else
					MOTDClientTracker[i] = nil
				end
			else
				MOTDClientTracker[i] = nil
			end
		end
		if #MOTDClientTracker == 0 then
			DAKDeregisterEventHook("kDAKOnServerUpdate", ProcessRemainingMOTDMessages)
		end
	end
	
end

local function MOTDOnClientConnect(client)

	if client:GetIsVirtual() then
		return false
	end
	
	if VerifyClient(client) == nil then
		return true
	end
	
	if IsAcceptedClient(client) then
		return false
	end
	
	local PEntry = { ID = client:GetUserId(), Client = client, Message = 1, Time = 0 }
	PEntry = ProcessMessagesforUser(PEntry)
	if PEntry ~= nil then
		if #MOTDClientTracker == 0 then
			DAKRegisterEventHook("kDAKOnServerUpdate", ProcessRemainingMOTDMessages, 5)
		end
		table.insert(MOTDClientTracker, PEntry)
	end
end

DAKRegisterEventHook("kDAKOnClientDelayedConnect", MOTDOnClientConnect, 5)

local function OnCommandAcceptMOTD(client)

	if client ~= nil then

		if IsAcceptedClient(client) then
			DAKDisplayMessageToClient(client, "kMOTDAlreadyAccepted")
			return
		end
		
		local steamid = client:GetUserId()
		local player = client:GetControllingPlayer()
		local name = "acceptedclient"

		if player ~= nil then
			name = player:GetName()
		end
		
		if tonumber(steamid) == nil then
			return
		end
		
		local NewClient = { }
		NewClient.id = tonumber(steamid)
		NewClient.revision = kDAKConfig.MOTD.kMOTDMessageRevision
		NewClient.name = name
		
		DAKDisplayMessageToClient(client, "kMOTDAccepted")
		table.insert(kDAKSettings.MOTDAcceptedClients, NewClient)
		
		SaveDAKSettings()
	end
	
end

Event.Hook("Console_acceptmotd",                 OnCommandAcceptMOTD)

local function OnCommandPrintMOTD(client)

	local PEntry = { ID = client:GetUserId(), Client = client, Message = 1, Time = 0 }
	PEntry = ProcessMessagesforUser(PEntry)
	if PEntry ~= nil then
		if #MOTDClientTracker == 0 then
			DAKRegisterEventHook("kDAKOnServerUpdate", ProcessRemainingMOTDMessages, 5)
		end
		table.insert(MOTDClientTracker, PEntry)
	end
	
end

Event.Hook("Console_printmotd",                 OnCommandPrintMOTD)

local function OnMOTDChatMessage(message, playerName, steamId, teamNumber, teamOnly, client)

	if client and steamId and steamId ~= 0 then
		for c = 1, #kDAKConfig.MOTD.kAcceptMOTDChatCommands do
			local chatcommand = kDAKConfig.MOTD.kAcceptMOTDChatCommands[c]
			if string.upper(message) == string.upper(chatcommand) then
				OnCommandAcceptMOTD(client)
				return true
			end
		end
		for c = 1, #kDAKConfig.MOTD.kPrintMOTDChatCommands do
			local chatcommand = kDAKConfig.MOTD.kPrintMOTDChatCommands[c]
			if string.upper(message) == string.upper(chatcommand) then
				OnCommandPrintMOTD(client)
				return true
			end
		end
	end

end

DAKRegisterEventHook("kDAKOnClientChatMessage", OnMOTDChatMessage, 5)