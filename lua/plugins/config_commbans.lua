//CommBans default config

kDAKRevisions["commbans"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.CommBans = { }
	kDAKConfig.CommBans.kMinVotesNeeded = 2
	kDAKConfig.CommBans.kTeamVotePercentage = .5
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "commbans", DefaultConfig = SetupDefaultConfig })