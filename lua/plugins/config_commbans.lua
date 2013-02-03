//CommBans default config

kDAKRevisions["commbans"] = "0.1.203a"

local function SetupDefaultConfig()
	kDAKConfig.CommBans = { }
	kDAKConfig.CommBans.kMinVotesNeeded = 2
	kDAKConfig.CommBans.kTeamVotePercentage = .5
end

DAKRegisterEventHook("kDAKPluginDefaultConfigs", {PluginName = "commbans", DefaultConfig = SetupDefaultConfig })