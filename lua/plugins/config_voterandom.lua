//reservedslots config

kDAKRevisions["voterandom"] = "0.1.118a"

local function SetupDefaultConfig()
	kDAKConfig.VoteRandom = { }
	kDAKConfig.VoteRandom.kVoteRandomInstantly = false
	kDAKConfig.VoteRandom.kVoteRandomAlwaysEnabled = false
	kDAKConfig.VoteRandom.kVoteRandomDuration = 30
	kDAKConfig.VoteRandom.kVoteRandomMinimumPercentage = 60
	kDAKConfig.VoteRandom.kVoteRandomChatCommands = { "voterandom", "random" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "voterandom", DefaultConfig = SetupDefaultConfig })