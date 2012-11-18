//enhanced logging default config

kDAKRevisions["EnhancedLogging"] = 1.6
local function SetupDefaultConfig(Save)
	if kDAKConfig.EnhancedLogging == nil then
		kDAKConfig.EnhancedLogging = { }
	end
	kDAKConfig.EnhancedLogging.kEnabled = true
	kDAKConfig.EnhancedLogging.kEnhancedLoggingSubDir = "Logs"
	kDAKConfig.EnhancedLogging.kServerTimeZoneAdjustment = 0
	if Save then
		SaveDAKConfig()
	end
end

table.insert(kDAKPluginDefaultConfigs, {PluginName = "EnhancedLogging", DefaultConfig = function(Save) SetupDefaultConfig(Save) end })

if kDAKConfig.EnhancedLogging == nil then
	SetupDefaultConfig(false)
end