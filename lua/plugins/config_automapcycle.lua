//automapcycle default config

kDAKRevisions["automapcycle"] = "0.1.119a"

local function SetupDefaultConfig()
	kDAKConfig.AutoMapCycle = { }
	kDAKConfig.AutoMapCycle.kAutoMapCycleDuration = 30
	kDAKConfig.AutoMapCycle.kMaximumPlayers = 0
	kDAKConfig.AutoMapCycle.kUseStandardMapCycle = true
	kDAKConfig.AutoMapCycle.kMapCycleMaps = { "ns2_tram", "ns2_summit", "ns2_veil" }
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "automapcycle", DefaultConfig = SetupDefaultConfig })