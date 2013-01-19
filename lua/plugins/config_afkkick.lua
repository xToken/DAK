//afkkick default config

kDAKRevisions["afkkick"] = "0.1.118a"

local function SetupDefaultConfig()
	kDAKConfig.AFKKicker = { }
	kDAKConfig.AFKKicker.kAFKKickDelay = 150
	kDAKConfig.AFKKicker.kAFKKickCheckDelay = 5
	kDAKConfig.AFKKicker.kAFKKickMinimumPlayers = 5
	kDAKConfig.AFKKicker.kAFKKickWarning1 = 30
	kDAKConfig.AFKKicker.kAFKKickWarning2 = 10
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "afkkick", DefaultConfig = SetupDefaultConfig })