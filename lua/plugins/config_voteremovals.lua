//VoteRemovals config

kDAKRevisions["VoteRemovals"] = 1.0
local function SetupDefaultConfig()
	kDAKConfig.VoteRemovals = { }
	kDAKConfig.VoteRemovals.kEnabled = true
	kDAKConfig.VoteRemovals.kVoteRemovalMinimumPercentage = 60
	kDAKConfig.VoteRemovals.kVoteRemovalVotingTime = 65
	kDAKConfig.VoteRemovals.kVoteRemovalAlertDelay = 16
	kDAKConfig.VoteRemovals.kVoteRemovalBanDuration = 15
	SaveDAKConfig()
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "VoteRemovals", DefaultConfig = function() SetupDefaultConfig() end })

if kDAKConfig.VoteRemovals == nil then
	SetupDefaultConfig()
end
