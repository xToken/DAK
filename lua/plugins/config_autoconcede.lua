//autoconcede default config

kDAKRevisions["autoconcede"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.AutoConcede = { }
	kDAKConfig.AutoConcede.kImbalanceDuration = 30
	kDAKConfig.AutoConcede.kImbalanceNotification = 10
	kDAKConfig.AutoConcede.kImbalanceAmount = 4
	kDAKConfig.AutoConcede.kMinimumPlayers = 6
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "autoconcede", DefaultConfig = SetupDefaultConfig })