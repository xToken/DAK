//votesurrender config

kDAKRevisions["votesurrender"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.VoteSurrender = { }
	kDAKConfig.VoteSurrender.kVoteSurrenderMinimumPercentage = 60
	kDAKConfig.VoteSurrender.kVoteSurrenderVotingTime = 120
	kDAKConfig.VoteSurrender.kVoteSurrenderAlertDelay = 20
	kDAKConfig.VoteSurrender.kSurrenderChatCommands = { "surrender" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "votesurrender", DefaultConfig = SetupDefaultConfig })