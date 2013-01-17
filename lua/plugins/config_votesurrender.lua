//votesurrender config

kDAKRevisions["VoteSurrender"] = "0.1.116a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.VoteSurrender == nil then
		kDAKConfig.VoteSurrender = { }
	end
	kDAKConfig.VoteSurrender.kVoteSurrenderMinimumPercentage = 60
	kDAKConfig.VoteSurrender.kVoteSurrenderVotingTime = 120
	kDAKConfig.VoteSurrender.kVoteSurrenderAlertDelay = 20
	kDAKConfig.VoteSurrender.kSurrenderChatCommands = { "surrender" }
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "VoteSurrender", DefaultConfig = SetupDefaultConfig })