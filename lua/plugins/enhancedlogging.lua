//NS2 EnhancedLogging and Tracking of events

local EnhancedLoggingFile = nil
local lastlogupdate = 0
local pendinglogsave = false
local EnhancedLog = { }

//*******************************************************************************************************************************
//Log Formatting Functions
//*******************************************************************************************************************************

local function GetClientIPAddress(client)

	if client ~= nil then
		return string.format(" address %s", IPAddressToString(Server.GetClientAddress(client)))
	end
	return ""
end

local function GetFormattedPositions(attackerOrigin, targetOrigin)
	
	if attackerOrigin ~= nil and targetOrigin ~= nil then
		local attackerx = string.format("%.3f", attackerOrigin.x)
		local attackery = string.format("%.3f", attackerOrigin.y)
		local attackerz = string.format("%.3f", attackerOrigin.z)
		local targetx = string.format("%.3f", targetOrigin.x)
		local targety = string.format("%.3f", targetOrigin.y)
		local targetz = string.format("%.3f", targetOrigin.z)
		return string.format("(attacker_position %f %f %f) (victim_position %f %f %f)", attackerx, attackery, attackerz, targetx, targety, targetz)
		
	end
	
	return ""
end

	
//*******************************************************************************************************************************
//Logging Functions
//*******************************************************************************************************************************

local function SaveEnhancedLog()

	local ELogFile = assert(io.open("config://" .. DAK.config.enhancedlogging.kEnhancedLoggingSubDir .. "\\" .. EnhancedLoggingFile, "w"))
	if ELogFile then
		for i = 1, #EnhancedLog do
			ELogFile:write(EnhancedLog[i] .. "\n")
		end
		ELogFile:close()
	end		
	lastlogupdate = Shared.GetTime()
	pendinglogsave = false
	
end

local function UpdateServerEnhancedLogging()
	if pendinglogsave then
		if lastlogupdate + DAK.config.enhancedlogging.kLogWriteDelay < Shared.GetTime() then
			SaveEnhancedLog()
			DAK:DeregisterEventHook("OnServerUpdate", UpdateServerEnhancedLogging)
		end
	end
end

local function PrintToEnhancedLog(logstring)

	if EnhancedLoggingFile == nil and Shared.GetMapName() ~= "" then
		EnhancedLoggingFile = string.format("%s - %s.txt", DAK:GetDateTimeString(true), tostring(Shared.GetMapName()))
	end
	table.insert(EnhancedLog, logstring)
	if EnhancedLoggingFile == nil then
		return
	end
	if lastlogupdate + DAK.config.enhancedlogging.kLogWriteDelay < Shared.GetTime() then
		SaveEnhancedLog()
	else
		pendinglogsave = true
		DAK:RegisterEventHook("OnServerUpdate", UpdateServerEnhancedLogging, 5, "enhancedlogging")
	end
	
	//Append doesnt crash atleast now, still doesnt work tho which is prettty meh.
	/*local ELogFile = io.open("config://" .. DAK.config.enhancedlogging.kEnhancedLoggingSubDir .. "\\" .. EnhancedLoggingFile, "a+")
	if ELogFile then
		ELogFile:seek("end")
		ELogFile:write(logstring .. "\n")
		ELogFile:close()
	else
		local ELogFile = io.open("config://" .. DAK.config.enhancedlogging.kEnhancedLoggingSubDir .. "\\" .. EnhancedLoggingFile, "w")
		if ELogFile then
			ELogFile:write(logstring .. "\n")
			ELogFile:close()
		end
	end*/

end

function EnhancedLogMessage(message)
	PrintToEnhancedLog(DAK:GetTimeStamp() .. message)
end

local function LogOnClientConnect(client)

	if client ~= nil then
		//Shared.Message( DAK:GetTimeStamp() .. DAK:GetClientUIDString(client) .. " connected," .. GetClientIPAddress(client))
		EnhancedLogMessage(DAK:GetClientUIDString(client) .. " connected," .. GetClientIPAddress(client))
	end
	
end

DAK:RegisterEventHook("OnClientDelayedConnect", LogOnClientConnect, 5, "enhancedlogging")

local function LogOnClientDisconnect(client)
	local reason = ""
	if client ~= nil then
		if client.disconnectreason ~= nil then
			reason = client.disconnectreason
		end
		//Shared.Message(DAK:GetTimeStamp() .. DAK:GetClientUIDString(client) .. " disconnected, " .. reason)
		EnhancedLogMessage(DAK:GetClientUIDString(client) .. " disconnected, " .. reason)
	end
	
end

DAK:RegisterEventHook("OnClientDisconnect", LogOnClientDisconnect, 5, "enhancedlogging")

function OnCommandSetName(client, name)

	if client ~= nil and name ~= nil then

		local player = client:GetControllingPlayer()

		name = TrimName(name)

		if name ~= player:GetName() and name ~= kDefaultPlayerName and string.len(name) > 0 then
		
			EnhancedLogMessage(DAK:GetClientUIDString(client) .. " changed name to " .. name .. ".")
			
			local prevName = player:GetName()
			player:SetName(name)
			if prevName == kDefaultPlayerName then
				Server.Broadcast(nil, string.format("%s connected.", player:GetName()))
			elseif prevName ~= player:GetName() then
				Server.Broadcast(nil, string.format("%s is now known as %s.", prevName, player:GetName()))
			end
			
		end
	
	end

end

Event.Hook("Console_name",               OnCommandSetName)
	
local function OnPluginInitialized()
		
	local originalNS2CommandStructureLoginPlayer
	
	originalNS2CommandStructureLoginPlayer = DAK:Class_ReplaceMethod("CommandStructure", "LoginPlayer", 
		function(self, player)
		
			if player then
				local Client = Server.GetOwner(player)
				local teamNum = self:GetTeamNumber()
				if Client and teamNum then
					EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " logged into commander for team " .. ToString(teamNum))
				end
			end
			originalNS2CommandStructureLoginPlayer( self, player )
		end
	)
	
	local originalNS2CommandStructureLogout
	
	originalNS2CommandStructureLogout = DAK:Class_ReplaceMethod("CommandStructure", "Logout", 
		function(self)
		
			local commander = self:GetCommander()
			if commander then
				local Client = Server.GetOwner(commander)
				local teamNum = self:GetTeamNumber()
				if Client and teamNum then
					EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " logged out of commander for team " .. ToString(teamNum))
				end
			end
			originalNS2CommandStructureLogout( self )
		end
	)
	
	local originalNS2RecycleMixinOnResearchComplete
	
	originalNS2RecycleMixinOnResearchComplete = DAK:Class_ReplaceMethod("RecycleMixin", "OnResearchComplete", 
		function(self, researchId)
		
			local buildingID = self:GetId()
			local buildingname = self:GetClassName()
			if researchId == kTechId.Recycle then        
				EnhancedLogMessage(buildingname .. " id: " .. ToString(buildingID) .. " was recycled.")
			end
			originalNS2RecycleMixinOnResearchComplete( self, researchId )
		end
	)
	
	/*local originalNS2RecycleMixinOnResearch
	
	originalNS2RecycleMixinOnResearch = DAK:Class_ReplaceMethod("RecycleMixin", "OnResearch", 
		function(self, researchId)
		
			local buildingID = self:GetId()
			local buildingname = self:GetClassName()
			local team = self:GetTeam()
			if team then
				local commander = team:GetCommander()
				if commander then
					local Client = Server.GetOwner(commander)
					if researchId == kTechId.Recycle and Client then        
						EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " started recycle of " .. buildingname .. " id: " .. ToString(buildingID))
					end
				end
			end
			originalNS2RecycleMixinOnResearch( self, researchId )
		end
	)*/
	
	local originalNS2ResearchMixinSetResearching
	
	originalNS2ResearchMixinSetResearching = DAK:Class_ReplaceMethod("ResearchMixin", "SetResearching", 
		function(self, techNode, player)
		
			local researchname = EnumToString(kTechId, techNode.techId)
			local buildingID = self:GetId()
			local buildingname = self:GetClassName()
			if player then
				local Client = Server.GetOwner(player)
				if Client then        
					EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " started research of " .. researchname .. " on " .. buildingname .. " id: " .. ToString(buildingID))
				end
			end
			originalNS2ResearchMixinSetResearching( self, techNode, player )
		end
	)
	
	local originalNS2ResearchMixinPerformAction
	
	originalNS2ResearchMixinPerformAction = DAK:Class_ReplaceMethod("ResearchMixin", "PerformAction", 
		function(self, techNode, position)
		
			if techNode.techId == kTechId.Cancel and self:GetIsResearching() then
				local researchname = EnumToString(kTechId, self.researchingId)
				local buildingID = self:GetId()
				local buildingname = self:GetClassName()
				local team = self:GetTeam()
				if team then
					local commander = team:GetCommander()
					if commander then
						local Client = Server.GetOwner(commander)
						if Client then        
							EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " cancelled research of " .. researchname .. " on " .. buildingname .. " id: " .. ToString(buildingID))
						end
					end
				end
			end
			originalNS2ResearchMixinPerformAction( self, techNode, position )
		end
	)
	
	local originalNS2ConstructMixinOnInitialized
	
	originalNS2ConstructMixinOnInitialized = DAK:Class_ReplaceMethod("ConstructMixin", "OnInitialized", 
		function(self)
		
			local buildingID = self:GetId()
			local buildingname = self:GetClassName()
			local team = self:GetTeam()
			if team then
				local owner = self:GetOwner()
				if owner == nil then
					owner = team:GetCommander()
				end
				if owner then
					local Client = Server.GetOwner(owner)
					if Client then        
						EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " started construction of " .. buildingname .. " id: " .. ToString(buildingID))
					end
				end
			end
			originalNS2ConstructMixinOnInitialized( self )
		end
	)
	
end

if DAK.config and DAK.config.loader and DAK.config.loader.GamerulesExtensions then
	DAK:RegisterEventHook("OnPluginInitialized", OnPluginInitialized, 5, "enhancedlogging")
end

function EnhancedLoggingChatMessage(message, playerName, ns2id, teamNumber, teamOnly, client)
	if client and ns2id and ns2id ~= 0 then
		EnhancedLogMessage(DAK:GetClientUIDString(client) .. ConditionalValue(teamOnly, " teamsay ", " say ") .. message)
	else
		EnhancedLogMessage(playerName .. ConditionalValue(teamOnly, " teamsay ", " say ")  .. message)
	end
end

DAK:RegisterEventHook("OnClientChatMessage", EnhancedLoggingChatMessage, 5, "enhancedlogging")

local function EnhancedLoggingSetGameState(self, state, currentstate)

	if state ~= currentstate then
		if state == kGameState.Started then
			local version = ToString(Shared.GetBuildNumber())
			local map = Shared.GetMapName()
			EnhancedLogMessage("game_started" .. " build " .. version .. " map " .. map)
		end
	end
	
end

DAK:RegisterEventHook("OnSetGameState", EnhancedLoggingSetGameState, 5, "enhancedlogging")

function EnhancedLoggingJoinTeam(self, player, newTeamNumber, force)

	local client = Server.GetOwner(player)
	if client ~= nil then
		EnhancedLogMessage(string.format("%s joined team %s.", DAK:GetClientUIDString(client), newTeamNumber))
	end
	
end

DAK:RegisterEventHook("OnTeamJoin", EnhancedLoggingJoinTeam, 5, "enhancedlogging")

function EnhancedLoggingEndGame(self, winningTeam)

	local version = ToString(Shared.GetBuildNumber())
	local winner = ToString(winningTeam:GetTeamType())
	local length = string.format("%.2f", Shared.GetTime() - self.gameStartTime)
	local map = Shared.GetMapName()
	local start_location1 = self.startingLocationNameTeam1
	local start_location2 = self.startingLocationNameTeam2
	EnhancedLogMessage("game_ended" .. " build " .. version .. " winning_team " .. winner .. " game_length " .. length .. 
		" map " .. map .. " marine_start_loc " .. start_location1 .. " alien_start_loc " .. start_location2)
	
end

DAK:RegisterEventHook("OnGameEnd", EnhancedLoggingEndGame, 5, "enhancedlogging")

function EnhancedLoggingCastVoteByPlayer(self, voteTechId, player)

	if voteTechId == kTechId.VoteDownCommander1 or voteTechId == kTechId.VoteDownCommander2 or voteTechId == kTechId.VoteDownCommander3 then 
		local playerIndex = (voteTechId - kTechId.VoteDownCommander1 + 1)        
		local commanders = GetEntitiesForTeam("Commander", player:GetTeamNumber())
		
		if playerIndex <= table.count(commanders) then
			local targetCommander = commanders[playerIndex]
			if targetCommander ~= nil then
				local targetClient = Server.GetOwner(targetCommander)
				local Client = Server.GetOwner(player)
				if targetClient and Client then
					EnhancedLogMessage(DAK:GetClientUIDString(Client) .. " voted to eject " .. DAK:GetClientUIDString(targetClient))
				end
			end
		end
	end
	
end

DAK:RegisterEventHook("OnCastVoteByPlayer", EnhancedLoggingCastVoteByPlayer, 5, "enhancedlogging")

function EnhancedLoggingOnEntityKilled(self, targetEntity, attacker, doer, point, direction)
 
	if attacker and targetEntity and doer then
		local attackerOrigin = attacker:GetOrigin()
		local targetOrigin = targetEntity:GetOrigin()
		local attacker_client = Server.GetOwner(attacker)
		local target_client = Server.GetOwner(targetEntity)
		if target_client == nil and attacker_client == nil then
			EnhancedLogMessage(attacker:GetClassName() .. " killed " .. targetEntity:GetClassName() .. " with " .. doer:GetClassName() .. " at " .. GetFormattedPositions(attackerOrigin, targetOrigin))
		elseif target_client == nil then
			EnhancedLogMessage(DAK:GetClientUIDString(attacker_client) .. " killed " .. targetEntity:GetClassName() .. " with " .. doer:GetClassName() .. " at " .. GetFormattedPositions(attackerOrigin, targetOrigin))
		elseif attacker_client == nil then
			EnhancedLogMessage(attacker:GetClassName() .. " killed " .. DAK:GetClientUIDString(target_client) .. " with " .. doer:GetClassName() .. " at " .. GetFormattedPositions(attackerOrigin, targetOrigin))
		else
			EnhancedLogMessage(DAK:GetClientUIDString(attacker_client) .. " killed " .. DAK:GetClientUIDString(target_client) .. " with " .. doer:GetClassName() .. " at " .. GetFormattedPositions(attackerOrigin, targetOrigin))
		end
	end

end

DAK:RegisterEventHook("OnEntityKilled", EnhancedLoggingOnEntityKilled, 5, "enhancedlogging")