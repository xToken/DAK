//enhanced logging default config

kDAKRevisions["EnhancedLogging"] = 1.6
local function SetupDefaultConfig()
	kDAKConfig.EnhancedLogging = { }
	kDAKConfig.EnhancedLogging.kEnabled = true
	kDAKConfig.EnhancedLogging.kEnhancedLoggingSubDir = "Logs"
	kDAKConfig.EnhancedLogging.kServerTimeZoneAdjustment = 0
	SaveDAKConfig()
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "EnhancedLogging", DefaultConfig = function() SetupDefaultConfig() end })

if kDAKConfig.EnhancedLogging == nil then
	SetupDefaultConfig()
end