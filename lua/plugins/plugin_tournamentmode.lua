//NS2 Tournament Mod Server side script

local TournamentModeSettings = { countdownstarted = false, countdownstarttime = 0, countdownstartcount = 0, lastmessage = 0, official = false}

if kDAKConfig and kDAKConfig.TournamentMode and kDAKConfig.TournamentMode.kEnabled then

	if kDAKSettings.TournamentMode == nil then
		local TournamentMode = false
		table.insert(kDAKSettings, TournamentMode)
	end
	
	if kDAKSettings.FriendlyFire == nil then
		local FriendlyFire = false
		table.insert(kDAKSettings, FriendlyFire)
	end

	local function LoadTournamentMode()
		if kDAKSettings.TournamentMode then
			Shared.Message("TournamentMode Enabled")
			//EnhancedLog("TournamentMode Enabled")
		else
			kDAKSettings.TournamentMode = false
		end
		if kDAKSettings.FriendlyFire then
			Shared.Message("FriendlyFire Enabled")
			//EnhancedLog("FriendlyFire Enabled")
		else
			kDAKSettings.FriendlyFire = false
		end
	end

	LoadTournamentMode()

	function GetTournamentMode()
		return kDAKSettings.TournamentMode
	end
	
	table.insert(kDAKCheckMapChange, function() return GetTournamentMode() end)

	function GetFriendlyFire()
		return kDAKSettings.FriendlyFire
	end
	
	local function StartCountdown(gamerules)
		if gamerules then
			gamerules:ResetGame() 
			gamerules:ResetGame()
			gamerules:SetGameState(kGameState.Countdown)      
			gamerules.countdownTime = kCountDownLength     
			gamerules.lastCountdownPlayed = nil 
		end
    end
	
	local function ClearTournamentModeState()
		TournamentModeSettings[1] = {ready = false, lastready = 0, captain = nil}
		TournamentModeSettings[2] = {ready = false, lastready = 0, captain = nil}
		TournamentModeSettings.countdownstarted = false
		TournamentModeSettings.countdownstarttime = 0
		TournamentModeSettings.countdownstartcount = 0
		TournamentModeSettings.lastmessage = 0
	end
	
	ClearTournamentModeState()
	
	local function DisplayNotification(message)
		Shared.Message(message)
		EnhancedLog(message)
		chatMessage = string.sub(message, 1, kMaxChatLength)
		Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Admin", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
	end
	
	local function CheckCancelGameStart()
		if TournamentModeSettings.countdownstarttime ~= 0 then
			DisplayNotification("Game start cancelled.")
			TournamentModeSettings.countdownstarttime = 0
			TournamentModeSettings.countdownstartcount = 0
			TournamentModeSettings.countdownstarted = false
		end
	end
	
	local function MonitorCountDown()
	
		if TournamentModeSettings.countdownstarted then	
								
			if TournamentModeSettings.countdownstarttime - TournamentModeSettings.countdownstartcount < Shared.GetTime() and TournamentModeSettings.countdownstartcount ~= 0 then
				if (math.fmod(TournamentModeSettings.countdownstartcount, 5) == 0 or TournamentModeSettings.countdownstartcount <= 5) then
					DisplayNotification(string.format(kDAKConfig.TournamentMode.kTournamentModeCountdown, TournamentModeSettings.countdownstartcount), 1, kMaxChatLength)
				end
				TournamentModeSettings.countdownstartcount = TournamentModeSettings.countdownstartcount - 1
			end
			
			if TournamentModeSettings.countdownstarttime < Shared.GetTime() then
				ClearTournamentModeState()
				local gamerules = GetGamerules()
				if gamerules ~= nil then
					StartCountdown(gamerules)
				end
			end
			
		end
		
	end
	
	local function MonitorPubMode(gamerules)
		
		if gamerules and gamerules:GetTeam1():GetNumPlayers() >= kDAKConfig.TournamentMode.kTournamentModePubMinPlayers and gamerules:GetTeam2():GetNumPlayers() >= kDAKConfig.TournamentMode.kTournamentModePubMinPlayers then
			if not TournamentModeSettings.countdownstarted then
				TournamentModeSettings.countdownstarted = true
				TournamentModeSettings.countdownstarttime = Shared.GetTime() + kDAKConfig.TournamentMode.kTournamentModeGameStartDelay
				TournamentModeSettings.countdownstartcount = kDAKConfig.TournamentMode.kTournamentModeGameStartDelay	
			end
		else
			CheckCancelGameStart()
			if TournamentModeSettings.lastpubmessage + kDAKConfig.TournamentMode.kTournamentModePubAlertDelay < Shared.GetTime() then
				DisplayNotification(string.format(kDAKConfig.TournamentMode.kTournamentModePubPlayerWarning, kDAKConfig.TournamentMode.kTournamentModePubMinPlayers), 1, kMaxChatLength)
				TournamentModeSettings.lastpubmessage = Shared.GetTime()
			end
		end

	end
	
	local function TournamentModeOnDisconnect(client)
		if TournamentModeSettings.countdownstarted and not kDAKConfig.TournamentMode.kTournamentModePubMode then
			CheckCancelGameStart()
		end
	end
	
	table.insert(kDAKOnClientDisconnect, function(client) return TournamentModeOnDisconnect(client) end)
		
	local function UpdatePregame(timePassed)
	
		local gamerules = GetGamerules()
		if gamerules and GetTournamentMode() and not Shared.GetCheatsEnabled() and not Shared.GetDevMode() and gamerules:GetGameState() == kGameState.PreGame then
			if kDAKConfig.TournamentMode.kTournamentModePubMode then
				MonitorPubMode(gamerules)
			end
			MonitorCountDown()
			return false
		end
		return true
		
	end
		
	table.insert(kDAKOnUpdatePregame, function(timePassed) return UpdatePregame(timePassed) end)
	
	if kDAKConfig and kDAKConfig.DAKLoader and kDAKConfig.DAKLoader.GamerulesExtensions then
	
		local originalNS2GRGetCanJoinTeamNumber
		
		originalNS2GRGetCanJoinTeamNumber = Class_ReplaceMethod(kDAKConfig.DAKLoader.GamerulesClassName, "GetCanJoinTeamNumber", 
			function(self, teamNumber)
	
				if GetTournamentMode() and (teamNumber == 1 or teamNumber == 2) then
					return true
				end
				return originalNS2GRGetCanJoinTeamNumber(self, teamNumber)
				
			end
		)
		
	end
	
	local function EnablePCWMode(client)
		DisplayNotification("PCW Mode set, team captains not required.")
	end	
	
	local function EnableOfficialMode(client)
		DisplayNotification("Official Mode set, team captains ARE required.")
		//eventually add additional req. for offical matches
	end

	local function OnCommandTournamentMode(client, state, ffstate, newmode)
		local alert = false
		if (state ~= true or state ~= false) and state ~= nil then
			local newstate = tonumber(state)
			assert(type(newstate) == "number")
			if newstate > 0 then
				state = true
			else
				state = false
			end
		end
		if (ffstate ~= true or ffstate ~= false) and ffstate ~= nil then
			local newffstate = tonumber(ffstate)
			assert(type(newffstate) == "number")
			if newffstate > 0 then
				ffstate = true
			else
				ffstate = false
			end
		end
		if (newmode ~= true or newmode ~= false) and newmode ~= nil then
			local newnummode = tonumber(newmode)
			assert(type(newnummode) == "number")
			if newnummode > 0 then
				newmode = true
			else
				newmode = false
			end
		end
		if client ~= nil and state ~= nil and state ~= GetTournamentMode() then
			kDAKSettings.TournamentMode = state
			ServerAdminPrint(client, "TournamentMode " .. ConditionalValue(GetTournamentMode(), "enabled", "disabled"))
			SaveDAKSettings()
			alert = true
		end
		if client ~= nil and ffstate ~= nil and ffstate ~= GetFriendlyFire() then
			kDAKSettings.FriendlyFire = ffstate
			ServerAdminPrint(client, "FriendlyFire " .. ConditionalValue(GetFriendlyFire(), "enabled", "disabled"))
			SaveDAKSettings()
			alert = true
		end
		if client ~= nil and newmode ~= nil and TournamentModeSettings.official ~= newmode then
			if newmode == true then
				EnableOfficialMode(client)
			elseif newmode == false then
				EnablePCWMode(client)
			end
			TournamentModeSettings.official = newmode
			alert = true
		end
		if client ~= nil then 		
			local player = client:GetControllingPlayer()
			if player ~= nil then
				PrintToAllAdmins("sv_tournamentmode", client, " " .. ToString(state) .. " " .. ToString(ffstate) .. " " .. ToString(newmode))
			end
			if not alert then
				ServerAdminPrint(client, string.format("Tournamentmode set to - " .. ToString(kDAKSettings.TournamentMode)
					.. " FriendlyFire set to - " .. ToString(kDAKSettings.FriendlyFire)
					.. " Official set to - ".. ToString(TournamentModeSettings.official)))
			end
		end
	end

	DAKCreateServerAdminCommand("Console_sv_tournamentmode", OnCommandTournamentMode, "<state> <ffstate> <mode> Enable/Disable tournament mode, friendlyfire or change mode (PCW/OFFICIAL).")
	
	local function OnCommandSetupCaptain(client, teamnum, captain)
	
		local tmNum = tonumber(teamnum)
		local cp = tonumber(captain)
		assert(type(tmNum) == "number")
		assert(type(cp) == "number")
		if tmNum == 1 or tmNum == 2 and client then
			if GetClientMatchingGameId(cp) then
				TournamentModeSettings[tmNum].captain = GetClientMatchingGameId(cp):GetUserId()
			else
				TournamentModeSettings[tmNum].captain = captain
			end
			ServerAdminPrint(client, string.format("Team captain for team %s set to %s", tmNum, TournamentModeSettings[tmNum].captain))
		end
		if client ~= nil then 
			local player = client:GetControllingPlayer()
			if player ~= nil then
				PrintToAllAdmins("sv_setcaptain", client, " " .. ToString(tmNum) .. " " .. ToString(cp))
			end
		end
		
	end
	
	DAKCreateServerAdminCommand("Console_sv_setcaptain", OnCommandSetupCaptain, "<team> <captain> Set the captain for a team by gameid/steamid.")
	
	local function OnCommandForceStartRound(client)
	
		ClearTournamentModeState()
		local gamerules = GetGamerules()
		if gamerules ~= nil then
			StartCountdown(gamerules)
		end
		
		if client ~= nil then 
			local player = client:GetControllingPlayer()
			if player ~= nil then
				PrintToAllAdmins("sv_forceroundstart", client)
			end
		end
	end
	
	DAKCreateServerAdminCommand("Console_sv_forceroundstart", OnCommandForceStartRound, "Force start a round in tournamentmode.")
	
	local function OnCommandCancelRoundStart(client)
	
		CheckCancelGameStart()
		ClearTournamentModeState()
		
		if client ~= nil then 
			local player = client:GetControllingPlayer()
			if player ~= nil then
				PrintToAllAdmins("sv_cancelroundstart", client)
			end
		end
	end
	
	DAKCreateServerAdminCommand("Console_sv_cancelroundstart", OnCommandCancelRoundStart, "Cancel the start of a round in tournamentmode.")

	local function CheckGameCountdownStart()
		if TournamentModeSettings[1].ready and TournamentModeSettings[2].ready then
			TournamentModeSettings.countdownstarted = true
			TournamentModeSettings.countdownstarttime = Shared.GetTime() + kDAKConfig.TournamentMode.kTournamentModeGameStartDelay
			TournamentModeSettings.countdownstartcount = kDAKConfig.TournamentMode.kTournamentModeGameStartDelay
		end
	end
	
	local function ClientReady(client)
	
		local player = client:GetControllingPlayer()
		local teamnum = player:GetTeamNumber()
		local clientid = client:GetUserId()
		if teamnum == 1 or teamnum == 2 then
			if TournamentModeSettings.official and TournamentModeSettings[teamnum].captain then			
				if TournamentModeSettings[teamnum].lastready + kDAKConfig.TournamentMode.kTournamentModeReadyDelay < Shared.GetTime() and TournamentModeSettings[teamnum].captain == clientid then
					TournamentModeSettings[teamnum].ready = not TournamentModeSettings[teamnum].ready
					TournamentModeSettings[teamnum].lastready = Shared.GetTime()
					DisplayNotification(string.format("%s has " .. ConditionalValue(TournamentModeSettings[teamnum].ready, "readied", "unreadied") .. " for Team %s.",clientid, teamnum))
					CheckGameCountdownStart()
				end
			elseif not TournamentModeSettings.official then
				if TournamentModeSettings[teamnum].lastready + kDAKConfig.TournamentMode.kTournamentModeReadyDelay < Shared.GetTime() then
					TournamentModeSettings[teamnum].ready = not TournamentModeSettings[teamnum].ready
					TournamentModeSettings[teamnum].lastready = Shared.GetTime()
					DisplayNotification(string.format("%s has " .. ConditionalValue(TournamentModeSettings[teamnum].ready, "readied", "unreadied") .. " for Team %s.",clientid, teamnum))
					CheckGameCountdownStart()
				end
			end
		end
		if teamoneready == false or teamtwoready == false then
			CheckCancelGameStart()
		end
		
	end

	local function OnCommandReady(client)
		local gamerules = GetGamerules()
		if gamerules ~= nil and client ~= nil then
			if GetTournamentMode() and (gamerules:GetGameState() == kGameState.NotStarted or gamerules:GetGameState() == kGameState.PreGame) and not kDAKConfig.TournamentMode.kTournamentModePubMode then
				ClientReady(client)
			end
		end
	end

	Event.Hook("Console_ready",                 OnCommandReady)
		
	local function OnTournamentModeChatMessage(message, playerName, steamId, teamNumber, teamOnly, client)
	
		if client and steamId and steamId ~= 0 then
			if message == "ready" then
				OnCommandReady(client)
			end
		end
	
	end
	
	table.insert(kDAKOnClientChatMessage, function(message, playerName, steamId, teamNumber, teamOnly, client) return OnTournamentModeChatMessage(message, playerName, steamId, teamNumber, teamOnly, client) end)
	
elseif kDAKConfig and not kDAKConfig.TournamentMode then
	
	DAKGenerateDefaultDAKConfig("TournamentMode")
		
end

Shared.Message("TournamentMode Loading Complete")