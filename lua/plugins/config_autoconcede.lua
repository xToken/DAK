//autoconcede default config

kDAKRevisions["AutoConcede"] = "0.1.114a"

local function SetupDefaultConfig(Save)
	if kDAKConfig.AutoConcede == nil then
		kDAKConfig.AutoConcede = { }
	end
	kDAKConfig.AutoConcede.kImbalanceDuration = 30
	kDAKConfig.AutoConcede.kImbalanceAmount = 4
	kDAKConfig.AutoConcede.kMinimumPlayers = 6
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "AutoConcede", DefaultConfig = SetupDefaultConfig })