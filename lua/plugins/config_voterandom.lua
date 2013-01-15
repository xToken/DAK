//reservedslots config

kDAKRevisions["VoteRandom"] = "0.1.114a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.VoteRandom == nil then
		kDAKConfig.VoteRandom = { }
	end
	kDAKConfig.VoteRandom.kVoteRandomInstantly = false
	kDAKConfig.VoteRandom.kVoteRandomDuration = 30
	kDAKConfig.VoteRandom.kVoteRandomMinimumPercentage = 60
	kDAKConfig.VoteRandom.kVoteRandomChatCommands = { "voterandom", "random" }
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "VoteRandom", DefaultConfig = SetupDefaultConfig })