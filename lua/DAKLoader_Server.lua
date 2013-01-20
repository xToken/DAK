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
	kDAKOnServerUpdateEveryFrame = { }		//Functions run on Every ServerUpdate
	kDAKOnClientDelayedConnect = { }		//Functions run on DelayedClientConnect
	kDAKOnTeamJoin = { }					//Functions run on TeamJoin from Gamerules
	kDAKOnGameEnd = { }						//Functions run on GameEnd from Gamerules
	kDAKOnEntityKilled = { }				//Functions run on EntityKilled from Gamerules
	kDAKOnUpdatePregame = { }				//Functions run on UpdatePregame from Gamerules
	kDAKOnCastVoteByPlayer = { }			//Functions run on CastVoteByPlayer from Gamerules
	kDAKOnSetGameState = { }			    //Functions run on SetGameState from Gamerules
	kDAKOnClientChatMessage = { }			//Functions run on ChatMessages
	kDAKCheckMapChange = { }	    		//List of functions run to confirm if map should change
	kDAKOverrideMapChange = { }	    		//Functions run before MapCycle
	
	//Other globals
	kDAKServerAdminCommands = { }			//List of ServerAdmin Commands
	kDAKPluginDefaultConfigs = { }			//List of functions to setup default configs per plugin
	
	kDAKRevisions["dakloader"] = "0.1.119a"
	
	function DAKRegisterEventHook(functionarray, eventfunction, p)
		//Register Event in Array
		p = tonumber(p)
		if p == nil then p = 5 end
		if functionarray ~= nil then
			table.insert(functionarray, {func = eventfunction, priority = p})
			table.sort(functionarray, function(f1, f2) return f1.priority < f2.priority end)
		end
	end
	
	function DAKDeregisterEventHook(functionarray, eventfunction)
		//Remove Event in Array
		if functionarray ~= nil then
			for i = 1, #functionarray do
				if functionarray[i].func == eventfunction then
					table.remove(functionarray, i)
					break
				end
			end
		end
	end
	
	function DAKExecuteEventHooks(event, ...)
		if #event ~= nil then
			if #event > 0 then
				for i = #event, 1, -1 do
					if event[i].func(...) then return true end
				end
			end
		end
		return false
	end
	
	//Hooks for logging functions
	function EnhancedLog(message)
	
		if DAKIsPluginEnabled("enhancedlogging") then
			EnhancedLogMessage(message)
		end
	
	end
		
	function PrintToAllAdmins(commandname, client, parm1)
	
		if DAKIsPluginEnabled("enhancedlogging") then
			EnhancedLoggingAllAdmins(commandname, client, parm1)
		end
	
	end

	function DAKCreateGUIVoteBase(id, OnMenuFunction, OnMenuUpdateFunction)
		if DAKIsPluginEnabled("guimenubase") then
			return CreateGUIMenuBase(id, OnMenuFunction, OnMenuUpdateFunction)
		end
		return false
	end

	function ShufflePlayerList()
	
		local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
		for i = #playerList, 1, -1 do
			if playerList[i]:GetTeamNumber() ~= 0 then
				table.remove(playerList, i)
			end
		end
		for i = 1, (#playerList) do
			r = math.random(1, #playerList)
			local iplayer = playerList[i]
			playerList[i] = playerList[r]
			playerList[r] = iplayer
		end
		return playerList
		
	end
	
	Script.Load("lua/dkjson.lua")
	Script.Load("lua/DAKLoader_Class.lua")
	Script.Load("lua/DAKLoader_ServerAdmin.lua")
	Script.Load("lua/DAKLoader_Config.lua")
	Script.Load("lua/DAKLoader_Settings.lua")
	
	if kBaseScreenHeight == nil then
		//Assume Server.lua has not been loaded already
		//This is probably not perfect, but assuming Server.lua was not loaded first generally means this is loaded from workshop, which would allow for the client side mods to work
		//hence loading shared defs.
		Script.Load("lua/Server.lua")
		//Script.Load("lua/DAKLoader_Shared.lua")
		//Shared file just offers net msg definitions required for menus.
	end

	Script.Load("lua/DAKLoader_EventHooks.lua")
	Script.Load("lua/DAKLoader_ServerAdminCommands.lua")
	Script.Load("lua/DAKLoader_PluginLoader.lua")
	Script.Load("lua/DAKLoader_Language.lua")
	
	SaveDAKSettings()
	
end