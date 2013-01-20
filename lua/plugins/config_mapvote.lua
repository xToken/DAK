//mapvote config

kDAKRevisions["mapvote"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.MapVote = { }
	kDAKConfig.MapVote.kRoundEndDelay = 2
	kDAKConfig.MapVote.kVoteStartDelay = 8
	kDAKConfig.MapVote.kVotingDuration = 30
	kDAKConfig.MapVote.kMapsToSelect = 7
	kDAKConfig.MapVote.kDontRepeatFor = 4
	kDAKConfig.MapVote.kVoteNotifyDelay = 6
	kDAKConfig.MapVote.kVoteChangeDelay = 4
	kDAKConfig.MapVote.kVoteMinimumPercentage = 25
	kDAKConfig.MapVote.kRTVMinimumPercentage = 50
	kDAKConfig.MapVote.kExtendDuration = 15
	kDAKConfig.MapVote.kPregameLength = 15
	kDAKConfig.MapVote.kPregameNotifyDelay = 5
	kDAKConfig.MapVote.kMaximumExtends = 3
	kDAKConfig.MapVote.kMaximumTies = 1
	kDAKConfig.MapVote.kTimeleftChatCommands = { "timeleft" }
	kDAKConfig.MapVote.kRockTheVoteChatCommands = { "rtv", "rockthevote" }
	kDAKConfig.MapVote.kVoteChatCommands = { "vote" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "mapvote", DefaultConfig = SetupDefaultConfig })