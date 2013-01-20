//tournamentmode config

kDAKRevisions["tournamentmode"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.TournamentMode = { }
	kDAKConfig.TournamentMode.kTournamentModePubMode = false
	kDAKConfig.TournamentMode.kTournamentModeOverrideCanJoinTeam = true
	kDAKConfig.TournamentMode.kTournamentModePubMinPlayersPerTeam = 3
	kDAKConfig.TournamentMode.kTournamentModePubMinPlayersOnline = 8
	kDAKConfig.TournamentMode.kTournamentModePubGameStartDelay = 15
	kDAKConfig.TournamentMode.kTournamentModeAlertDelay = 30
	kDAKConfig.TournamentMode.kTournamentModeReadyDelay = 2
	kDAKConfig.TournamentMode.kTournamentModeGameStartDelay = 15
	kDAKConfig.TournamentMode.kTournamentModeCountdownDelay = 5
	kDAKConfig.TournamentMode.kReadyChatCommands = { "ready" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "tournamentmode", DefaultConfig = SetupDefaultConfig })