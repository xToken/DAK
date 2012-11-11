//autoconcede default config

kDAKRevisions["AutoConcede"] = 1.0
local function SetupDefaultConfig()
	kDAKConfig.AutoConcede = { }
	kDAKConfig.AutoConcede.kEnabled = true
	kDAKConfig.AutoConcede.kImbalanceDuration = 30
	kDAKConfig.AutoConcede.kImbalanceAmount = 4
	kDAKConfig.AutoConcede.kMinimumPlayers = 6
	kDAKConfig.AutoConcede.kWarningMessage = "Round will end in %s seconds due to imbalanced teams."
	kDAKConfig.AutoConcede.kConcedeMessage = "Round ended due to imbalanced teams."
	kDAKConfig.AutoConcede.kConcedeCancelledMessage = "Teams within autoconcede limits."
	SaveDAKConfig()
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "AutoConcede", DefaultConfig = function() SetupDefaultConfig() end })

if kDAKConfig.AutoConcede == nil then
	SetupDefaultConfig()
end
