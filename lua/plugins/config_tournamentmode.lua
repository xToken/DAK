//tournamentmode config

kDAKRevisions["TournamentMode"] = 2.6
local function SetupDefaultConfig(Save)
	if kDAKConfig.TournamentMode == nil then
		kDAKConfig.TournamentMode = { }
	end
	kDAKConfig.TournamentMode.kTournamentModePubMode = false
	kDAKConfig.TournamentMode.kTournamentModePubMinPlayers = 3
	kDAKConfig.TournamentMode.kTournamentModePubPlayerWarning = "Game will start once each team has %s players."
	kDAKConfig.TournamentMode.kTournamentModePubAlertDelay = 30
	kDAKConfig.TournamentMode.kTournamentModeReadyDelay = 2
	kDAKConfig.TournamentMode.kTournamentModeGameStartDelay = 15
	kDAKConfig.TournamentMode.kTournamentModeCountdown = "Game will start in %s seconds!"
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "TournamentMode", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.TournamentMode == nil then
	SetupDefaultConfig(false)
end