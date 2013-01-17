//CommBans default config

kDAKRevisions["CommBans"] = "0.1.116a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.CommBans == nil then
		kDAKConfig.CommBans = { }
	end
	kDAKConfig.CommBans.kMinVotesNeeded = 2
	kDAKConfig.CommBans.kTeamVotePercentage = .4
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "CommBans", DefaultConfig = SetupDefaultConfig })