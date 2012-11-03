//DAK Loader/Base Config

if Server then
	
	kDAKConfig = nil 						//Global variable storing all configuration items for mods
	kDAKSettings = nil 						//Global variable storing all settings for mods
	kDAKRevisions = { }						//List used to track revisions of plugins
	kDAKGameID = { }						//List of connected clients for GameID
	kDAKMapCycle = { }						//MapCycle.json information
	
	//DAK Hookable Functions
	kDAKOnClientConnect = { }				//Functions run on Client Connect
	kDAKOnClientDisconnect = { }			//Functions run on Client Disconnect
	kDAKOnServerUpdate = { }				//Functions run on ServerUpdate
	kDAKOnClientDelayedConnect = { }		//Functions run on DelayedClientConnect
	kDAKOnTeamJoin = { }					//Functions run on TeamJoin from Gamerules
	kDAKOnGameEnd = { }						//Functions run on GameEnd from Gamerules
	kDAKOnEntityKilled = { }				//Functions run on EntityKilled from Gamerules
	kDAKOnUpdatePregame = { }				//Functions run on UpdatePregame from Gamerules
	kDAKOnClientChatMessage = { }			//Functions run on ChatMessages
	kDAKCheckMapChange = { }	    		//List of functions run to confirm if map should change
	kDAKOverrideMapChange = { }	    		//Functions run before MapCycle
	
	//Other globals
	kDAKServerAdminCommands = { }			//List of ServerAdmin Commands
	kDAKPluginDefaultConfigs = { }			//List of functions to setup default configs per plugin
	
	Script.Load("lua/dkjson.lua")
	Script.Load("lua/DAKLoader_Class.lua")
	Script.Load("lua/DAKLoader_ServerAdmin.lua")
	Script.Load("lua/DAKLoader_Config.lua")
	Script.Load("lua/DAKLoader_Settings.lua")
	
	if kDAKConfig and kDAKConfig.DAKLoader and not kDAKConfig.DAKLoader.LoadFromServerLUA then
		Script.Load("lua/Server.lua")
		Script.Load("lua/DAKLoader_MapCycle.lua")
	end
	
	if kDAKConfig and kDAKConfig.DAKLoader and kDAKConfig.DAKLoader.LoadFromServerLUA then
		local DelayedEventOverrides = true
		local function DelayedEventOverride()	
			if DelayedEventOverrides then
				local chatMessageCount = 0

				function Server.AddChatToHistory(message, playerName, steamId, teamNumber, teamOnly)

					chatMessageCount = chatMessageCount + 1
					Server.recentChatMessages:Insert({ id = chatMessageCount, message = message, player = playerName,
													   steamId = steamId, team = teamNumber, teamOnly = teamOnly })

					local client = GetClientMatchingSteamId(steamId)
					if #kDAKOnClientChatMessage > 0 then
						for i = 1, #kDAKOnClientChatMessage do
							kDAKOnClientChatMessage[i](message, playerName, steamId, teamNumber, teamOnly, client)
						end
					end

				end
				Script.Load("lua/DAKLoader_MapCycle.lua")
				Shared.Message("Loading Event Overrides.")
				DelayedEventOverrides = false
			end
		end
		table.insert(kDAKOnServerUpdate, function(deltatime) return DelayedEventOverride() end)
	end
	
	Script.Load("lua/DAKLoader_EventHooks.lua")
	Script.Load("lua/DAKLoader_ServerAdminCommands.lua")
	
	kDAKRevisions["DAKLoader"] = 2.1
	
	//*****************************************************************************************************************
	//Globals
	//*****************************************************************************************************************
	
	//Hooks for logging functions
	function EnhancedLog(message)
	
		if kDAKConfig and kDAKConfig.EnhancedLogging and kDAKConfig.EnhancedLogging.kEnabled then
			EnhancedLogMessage(message)
		end
	
	end
		
	function PrintToAllAdmins(commandname, client, parm1)
	
		if kDAKConfig and kDAKConfig.EnhancedLogging and kDAKConfig.EnhancedLogging.kEnabled then
			EnhancedLoggingAllAdmins(commandname, client, parm1)
		end
	
	end

	function DAKCreateGUIVoteBase(OnVoteFunction, OnVoteUpdateFunction, Relevancy)
		if kDAKConfig and kDAKConfig.GUIVoteBase and kDAKConfig.GUIVoteBase.kEnabled then
			return CreateGUIVoteBase(OnVoteFunction, OnVoteUpdateFunction, Relevancy)
		end
		return false
	end

	function ShufflePlayerList()
	
		local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
		local gamerules = GetGamerules()
		for i = 1, (#playerList) do
			r = math.random(1, #playerList)
			local iplayer = playerList[i]
			playerList[i] = playerList[r]
			playerList[r] = iplayer
		end
		return playerList
		
	end
	
end